modelViewer = function() {
	
	scope = this;
	//just kidding we don't even use this
	//this.containerId = typeof containerId !== 'undefined' ? containerId : "";
	//var container = document.getElementById(containerId);

	var annotId = "annotations";

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
	var annot_obj = [];
	var annot_camera = [];
	var annot_text = [];
	var currentlyactive = 0;
	var initLoad = true;

	//Helper methods
	function v3(a,b,c) {
		return new THREE.Vector3(a,b,c);
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

	function loadAnnotations(){
		//get annotation from database

		var list = [];
		for (var i = 0; i< list.length; i++){
			annotate(list[i]["pos"],list[i]["camera"], list[i]["name"]);
		}
		initLoad = false;
	}

	function annotate(pos, cameraPos, name ){

		pos = typeof pos !== 'undefined' ? pos: v3(0,0,0);
		cameraPos = typeof cameraPos !== 'undefined' ? cameraPos: camera.position.clone();
		name = typeof name !== 'undefined' ? name: getAnnotationText();
		
		var sphereMaterial = new THREE.MeshLambertMaterial({ color: annotColor, shading: THREE.FlatShading });
		var sphere = new THREE.Mesh(
		  new THREE.SphereGeometry(
		    3, //radius
		    100, //segments
		    100), //rings
		  sphereMaterial);
		
		sphere.position = pos;
		
		if (name != null)
			addAnnotationObject(name, cameraPos, sphere);
	}

	function getAnnotationText(){
		var name = prompt("Please enter an annotation","");
		if (name!=null && name!="") {
			return name;
		} else {
			return null;
		}
	}

	function addAnnotationObject(name, camera, obj){
		annot_text.push(name);
		annot_camera.push(camera);
		annot_obj.push(obj);
		$("#annotation_list").append("<li>" + name + "</li>");

		if(!initLoad){
			//add to databas
		}

		scene.add(obj);
	}

	function viewAnnotation(annotPos) {
		var index = annotPos;
		positionCamera(annot_camera[index]);
		
		var annot_selector = "#" + annotId + " ul li:nth-child(" + (currentlyactive + 1) + ")";
		$(annot_selector).removeClass("active");

		currentlyactive = index;
		annot_selector = "#" + annotId + " ul li:nth-child(" + (currentlyactive + 1) + ")";
		$(annot_selector).addClass("active");
	}

	
	function animate() {
		requestAnimationFrame(animate);
		controls.update();
		render();
	}

	function render() {
		TWEEN.update();
		renderer.render(scene, camera);
	}

	function viewMouseDown(event) {
		event.preventDefault();

	    var vector = new THREE.Vector3(
	        ( event.clientX / WIDTH ) * 2 - 1,
	      - ( event.clientY / HEIGHT ) * 2 + 1,
	       	.5
	    );

	   	projector.unprojectVector( vector, camera );

	    var ray = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());
	   	ray.precision = 0.001;
	    var intersects_annots = ray.intersectObjects(annot_obj);
	    var intersects_objects = ray.intersectObjects(objects);

	    if (intersects_annots.length > 0 ){
	    	var annotIndex = annot_obj.indexOf(intersects_annots[0].object);
	    	if (annotIndex >= 0 )viewAnnotation(annotIndex); 
	    	else alert("Something weird is happening");
	    } 
	    else if (intersects_objects.length > 0){
	    	annotate(intersects_objects[0].point);
	    }
    }

    this.init = function(containerId){
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
		renderer.domElement.addEventListener('mousedown', viewMouseDown, false);

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

		loadAnnotations();

		$("#annotation_list").on("click", "li", function(){
			viewAnnotation($("#annotation_list li").index(this));
		});

		animate();
	}	

	this.loadObject = function(stlString, isString){

		alert("isString is" + isString);
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