modelViewer = function() {
	
	scope = this;

	var annotId = "annotations";
	var annotNum; 
	var objId;


	//Basic setup variables
	var WIDTH, HEIGHT;
	var VIEW_ANGLE, ASPECT, NEAR, FAR;
	var renderer, camera, scene;
	var objectColor = "#C0D8F0";
	var annotColor = "#FF8C00"; 

	//tween variable, currently only one
	var tween;

	//Controller variables
	var projector;
	var controls;

	//Annotation handling variables
	var objects = [];
	var annotations = [];
	var annot_obj = []; 
	var currentlyactive = 0;
	var initLoad = true;

	this.objects = objects;

	//****** Helper methods *******
	function error(s){
		console.log("ERROR: " + s);
	}
	function debug(s){
		//console.log(s);
	}

	function v3(a,b,c) {
		return new THREE.Vector3(a,b,c);
	}

	function v3ToString(v){
		return v.x + ',' + v.y + ',' + v.z;
	}

	function stringToV3(s){
		s = s.split(',');
		if (s.length != 3){
			error("string length wasn't 3 in stringToV3");
			return;
		} else{
			return v3(s[0], s[1], s[2]);
		}
	}
	function positionCamera(pos) {
	
		var oldpos = { x : camera.position.x, y: camera.position.y, z: camera.position.z };
		
		//to make the movement smooth
		tween = new TWEEN.Tween(oldpos).to(pos, 1000);
		tween.onUpdate(function(){
		    camera.position.x = oldpos.x;
		    camera.position.y = oldpos.y;
		    camera.position.z = oldpos.z;
		});
		tween.start();

		//always look at center! (or where object is)
		camera.lookAt(new THREE.Vector3(0,0,0));
		camera.updateMatrix();
	}

	//****** Annotation methods *******
	function loadAnnotations(list){
		for(var i =0; i< list.length; i++){
			annotate({"camera":stringToV3(list[i].camera), "coordinates":stringToV3(list[i].coordinates), "text":list[i].text});
		}
	}

	function annotate(annotation){
		
		debug("Reached annotate function");

		var cameraPos = typeof annotation.camera !== 'undefined' ? annotation.camera: camera.position.clone();
		var coordinates = typeof annotation.coordinates !== 'undefined' ? annotation.coordinates: v3(0,0,0);
		var text = typeof annotation.text !== 'undefined' ? annotation.text: getAnnotationText(); //TODO: have user annotations in a different place, maybe use the same function. this is not a good way
		
		if (text === "" || text === null){
			return;
		}
		debug("Annotation camera" + cameraPos + " coordinates" + coordinates + " text " + text);

		var sphereMaterial = new THREE.MeshLambertMaterial({ color: annotColor, shading: THREE.FlatShading });
		var sphere = new THREE.Mesh(
		  new THREE.SphereGeometry(
		    3, //radius
		    100, //segments
		    100), //rings
		  sphereMaterial);
		
		sphere.position = coordinates;
		
		addAnnotationObject(cameraPos, coordinates, text, sphere);
	}


	function getAnnotationText(){
		var name = prompt("Please enter an annotation","");
		if (name!=null && name!="") {
			return name;
		} else {
			return null;
		}
	}

	function addAnnotationObject(cameraPos, coordinates, text, obj){
		annotations.push({ "camera": cameraPos, "coordinates": coordinates, "text": text});
		annot_obj.push(obj); 
		annotNum ++;
		if(!initLoad){
			debug("Posting" + cameraPos + " " + coordinates + " " + text);
			$.post('/model_files/' + objId + '/annotations', {"camera": v3ToString(cameraPos), "coordinates": v3ToString(coordinates), "text": text});
		}

		$("#annotation_list").append("<li>" + text + "</li>");
		scene.add(obj);
	}

	function viewAnnotation(obj) {
		var objPos = annot_obj.indexOf(obj);
		if(objPos >= 0){
			debug("Viewing annotation" + objPos + " it is : ");
			debug(annotations);
			positionCamera(annotations[objPos].camera);
			highlightAnnotation(annotations[objPos].text, objPos);
		} 
	}
	function highlightAnnotation(text, pos){

		$("#" + annotId + " ul li").each(function(index){ 
			var el = $(this);
			if(index === pos) {
				el.addClass("active");
			} else {
				el.removeClass("active");
			}

		});
	}

	
	//**** Render methods ********
	function animate() {
		requestAnimationFrame(animate);
		controls.update();
		render();
	}

	function render() {
		TWEEN.update();
		renderer.render(scene, camera);
	}

	function viewMouseUp(event){
		if(moveFlag === 0){
			event.preventDefault();

		    var vector = new THREE.Vector3(
		        ( event.offsetX / WIDTH ) * 2 - 1,
		      - ( event.offsetY / HEIGHT ) * 2 + 1,
		       	.5
		    );


		   	projector.unprojectVector( vector, camera );

		    var ray = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());
		   	ray.precision = 0.001;
		    var intersects_annots = ray.intersectObjects(annot_obj);
		    var intersects_objects = ray.intersectObjects(objects);
		    if (intersects_annots.length > 0 ){
		    	
		    	var intersectAnnot = intersects_annots[0].object;

		    	if( intersectAnnot != null){
		    		viewAnnotation(intersectAnnot);
		    	}
		    	else error("Clicked on null object");
		    } 
		    else if (intersects_objects.length > 0){
		    	annotate({"camera": camera.position.clone(), "coordinates": intersects_objects[0].point});
		    	//TODO: replace with getUserAnnotation
		    }
	    }
	}


    //********** Public methods **************

    this.init = function(containerId, id){

    	objId = id;

		// set the scene size 
		WIDTH = 600;
		HEIGHT = 400;
		// set some camera attributes
		VIEW_ANGLE = 45;
		ASPECT = WIDTH / HEIGHT;
		NEAR = 0.1;
		FAR = 10000;

		//the projector is set up to capture mouse clicks
		projector = new THREE.Projector();
		renderer = new THREE.WebGLRenderer();
		renderer.setSize(WIDTH, HEIGHT);
		renderer.domElement.addEventListener('mousedown', function(){ moveFlag = 0;}, false);
		renderer.domElement.addEventListener('mouseup', viewMouseUp, false);
		renderer.domElement.addEventListener('mousemove', function(){moveFlag = 1;}, false);

		// camera = view angle, aspect, near, far
		camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);

		scene = new THREE.Scene();
		scene.add(camera);

		//mouse controls!
		controls = new THREE.TrackballControls(camera, renderer.domElement);
		controls.target.set( 0, 0, 0 )
		controls.rotateSpeed = .5;
		controls.zoomSpeed = .5;
		controls.panSpeed = 0.8;

		controls.noZoom = false;
		controls.noPan = false;

		controls.staticMoving = false;
		controls.dynamicDampingFactor = 0.15;

		controls.keys = [ 65, 83, 68 ];

		renderer.domElement.click(); //this hack is to get controls working immediately. it might not work
		
		$("#" + containerId).append(renderer.domElement);

		function addLight(){
			// create a point light
			var pointLight1 =
			  new THREE.PointLight(0xFFFFFF);

			// set its position
			pointLight1.position.x = 40;
			pointLight1.position.y = 50;
			pointLight1.position.z = 130;

			// add to the scene
			scene.add(pointLight1);

			var pointLight2 =
			  new THREE.PointLight(0xFFFFFF);

			// set its position
			pointLight2.position.x = -40;
			pointLight2.position.y = -50;
			pointLight2.position.z = -130;

			// add to the scene
			scene.add(pointLight2);

	     }

		addLight();
		positionCamera(v3(0,0,100));

		function drawPlane(){
			var planeMat = new THREE.MeshBasicMaterial({color: 0xFFAF96, wireframe:true, transparent: true});
			planeMat.opacity = 0.3;
			plane = new THREE.Mesh( new THREE.PlaneGeometry(100, 100, 10,10), planeMat);

			objects.push(plane);
			scene.add(plane);
		}

		drawPlane();

		$.getJSON('/model_files/' + objId + '/annotations', function (data){
			loadAnnotations(data);
			initLoad = false;
		})
		

		$("#annotation_list").on("click", "li", function(){
			viewAnnotation(annot_obj[$("#annotation_list li").index(this)]);
		});

		animate();
	}	

	this.loadObject = function(stlString, isString){

		//set up the loader and load in an object. 
		var loader = new THREE.STLLoader();

		$("#loader_status").html("Loading element");

		loader.addEventListener( 'load', function ( event ) {
				
			var geometry = event.content;
			$("#loader_status").html("Loaded element");

			var material = new THREE.MeshLambertMaterial({color:objectColor, shading: THREE.FlatShading});
			var mesh = new THREE.Mesh( geometry, material );

			mesh.position.set( 0, - 0.25, 0.6 );
			mesh.rotation.set( 0, - Math.PI / 2, 0 );
			var boundedBy = mesh.geometry.boundingSphere.radius;
			var scaleFactor = 25/boundedBy;
			mesh.scale.set(scaleFactor, scaleFactor, scaleFactor);
			objects.push(mesh);
			scene.add(mesh);

		});

		loader.load(stlString,  isString);
	}
}