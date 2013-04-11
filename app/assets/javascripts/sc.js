modelViewer = function(sceneContainer, annotationContainer, uniqueID) {

	//Essentials
	var camera;
	var renderer;
	var controller;

	//Scene variables
	var scene;
	var sceneID = uniqueID;
	var sceneElement = $(sceneContainer);
	var annotationContainer = annotationContainer;

	//Intersection variables
	var plane;
	var model;
	var annot;

	function debug(str){
		if(true){
			console.log(str);
		}
	}
	function animate() {
		requestAnimationFrame(animate);
		controller.controls.update();
		//TODO: UPDATE TWEEN!
		renderer.render(scene.scene, camera)
	}

	function moveCamera(newPosition) {
		camera.lookAt(new THREE.Vector3(0,0,0));
		camera.position = newPosition;
	}

	function init(){
		
		objects = [];
		//Set up scene
		scene = { "width": 800, "height": 450, "scene": new THREE.Scene()};	
		camera = new THREE.PerspectiveCamera(45, 1.77, scene.width /scene.height, 10000); //view_angle, aspect = width/height, near, far
		moveCamera(new THREE.Vector3(0,0,100));
		scene.scene.add(camera);

		//create and append renderer to sceneElement
		renderer = new THREE.WebGLRenderer();
		renderer.setSize(scene.width, scene.height);
		sceneElement.append(renderer.domElement);

		//Add event listeners
		renderer.domElement.addEventListener('mousedown', function(){ moveFlag = 0;}, false);
		renderer.domElement.addEventListener('mouseup', viewMouseUp, false);
		renderer.domElement.addEventListener('mousemove', viewMouseOver, false);

		//Set up the controls: This is boring stuff
		var controls = new THREE.TrackballControls(camera, renderer.domElement);
		controls.target.set( 0, 0, 0 ); controls.rotateSpeed = .5;	controls.zoomSpeed = .5; controls.panSpeed = 0.8;
		controls.noZoom = false; controls.noPan = false;  controls.staticMoving = false; controls.dynamicDampingFactor = 0.15;
		controls.keys = [65,83,68];
		controller = {"controls": controls, "projector": new THREE.Projector()};

		//Handling things!
		renderer.domElement.addEventListener('mousedown', function(){ moveFlag = 0;}, false);
		renderer.domElement.addEventListener('mouseup', viewMouseUp, false);
		renderer.domElement.addEventListener('mousemove', viewMouseOver, false);

		//Add lighting!
		var pointLight1 = new THREE.PointLight(0xFFFFFF);
		pointLight1.position = new THREE.Vector3(40,50,130);
		scene.scene.add(pointLight1);
		var pointLight2 = new THREE.PointLight(0xFFFFFF);
		pointLight2.position = new THREE.Vector3(-40,-50,-130);
		scene.scene.add(pointLight2);

		//Add plane!
		plane = new Plane();
		
		//initialize annotations
		annot = new Annotations(annotationContainer);
		annot.initializeAnnotations();

		animate();
		
	}

	//PLANE CLASS (subclass model?)
	Plane = function(){
		
		var plane;

		function createPlane(){
			var planeMat = new THREE.MeshBasicMaterial({color: 0xFFAF96, wireframe:true, transparent: true});
			planeMat.opacity = 0.3;
			plane = new THREE.Mesh( new THREE.PlaneGeometry(100, 100, 10,10), planeMat);
			scene.scene.add(plane);
		}

		this.intersects = function(ray){
			var intersect = ray.intersectObjects([plane]);
			if(intersect.length >0){
				debug("Intersected plane");
				annot.newAnnotation(intersect[0].point);
				return true;
			} else {
				return false;
			}
		}

		createPlane();
	}

	//CLASS MODEL
	Model = function(fileName, statusElement){

		var file = fileName;
		var loaderStatus_element = $(statusElement);

		var objectColor = "#C0D8F0";
		var object;

		//model.loadModel()
		this.load = function() {
			
			var loader = new THREE.STLLoader();
			$(loaderStatus_element).html("Loading element");
			
			loader.addEventListener( 'load', function ( event ) {
				
				var geometry = event.content;
				$(loaderStatus_element).html("Loaded element </br> s to zoom, a to pan");

				//Create material and mesh
				var material = new THREE.MeshLambertMaterial({color:objectColor, shading: THREE.FlatShading});
				var mesh = new THREE.Mesh( geometry, material );				
				var boundedBy = mesh.geometry.boundingSphere.radius;
				var scaleFactor = 25/boundedBy;			

				//Move the mesh around
				mesh.position.set( boundedBy ,0,0); //TODO: Calculate position and rotation better
				mesh.rotation.set( 0, - Math.PI / 2, 0 );
				mesh.scale.set(scaleFactor, scaleFactor, scaleFactor);
				
				object = mesh; //TODO: Do we need this anymore? For plane and stuff
				scene.scene.add(mesh);

			});

			loader.load(file);

		} //Close loadModel

		this.setColor = function(color) {
			objectColor = color;
		}

		this.intersects = function(ray){
			var intersect = ray.intersectObjects([object]);
			if(intersect.length >0){
				debug("Intersects model");
				annot.newAnnotation(intersect[0].point);
				return true;
			} else {
				return false;
			}
		}
	}

	this.addModel = function(fileName){
		model = new Model(fileName);
		objects.push(model.load());
		//objectModel.setColor("#eeee")
	}

	//CLASS ANNOTATIONS!!!!!
	Annotations = function(annotationContainer) {
		
		var annotationContainer_element = $(annotationContainer);
		var annotations = {};
		var annotation_obj = [];
		var annotation_id = []
		var annotColor = "#3079ed"; 

		function v3ToString(v){
			return v.x + ',' + v.y + ',' + v.z;
		}

		function stringToV3(s){
			s = s.split(',');
			if (s.length != 3){
				error("string length wasn't 3 in stringToV3");
				return;
			} else{
				return new THREE.Vector3(s[0], s[1], s[2]);
			}
		}

		function createMap(id, object) {
			annotation_obj.push(object);
			annotation_id.push(id);
		}
		function getIdWithObj(object){
			return annotation_id[annotation_obj.indexOf(object)];
		}
		function getIdWithHtml(html){
			return html.split('-')[1]
		}
		function parseAnnotation(annotJSON){
			var discussions = [];
			for (var i=0; i< annotJSON.discussions.length; i++){
				discussions.push({"uid": uid, "text": text});
			}
			return [{"camera": stringToV3(annotJSON.camera), 
					"coordinates": stringToV3(annotJSON.coordinates),
					"text": annotJSON.text,
					"discussions": discussions, 
					}, annotJSON.id]
		}

		function addAnnotation(annotObj, id){
			annotations[id] = annotObj;
			var sphereMaterial = new THREE.MeshLambertMaterial({ color: annotColor, shading: THREE.FlatShading });
			var sphere = new THREE.Mesh(
			  new THREE.SphereGeometry(
			    3, //radius
			    100, //segments
			    100), //rings
			  sphereMaterial);
			createMap(id, sphere);
			sphere.position = annotObj.coordinates;
			scene.scene.add(sphere);
		}


		function updateUI(){
			var annotation_html = "";
			console.log(annotations);
			for (var id in annotations){
				var annotObj = annotations[id];

				var discussion_html = "";
				for(var j=0; j< annotObj.discussions.length; j++){
					var discussionObj = annotObj.discussions;
					discussion_html += "<li> <div class='user'>" + discussionObj.uid + "</div>" +
											"<div class='text'>" + discussionObj.text + "</div> </li>";

				}
				//Finished with all the discussions
				discussion_html = "<ul class='discussions'>" + discussion_html + "</ul>"
				annotation_html += "<li id='annotation-" + id + "'>" + annotObj.text + discussion_html + "<input class='discussion_input' placeholder='Add to discussion'> </li>";
			} 
			//Finished with all the annotations
			annotationContainer_element.html(annotation_html);
		}

		function addDiscussion(element) {
			//TODO:!!
		}
		this.initializeAnnotations = function() {
			$.getJSON('/model_files/' + sceneID + '/annotations', function(data) {
				annotationList = data;
				console.log(data);
				for (var i =0; i <annotationList.length; i++) {
					var temp = parseAnnotation(annotationList[i]);
					addAnnotation(temp[0], temp[1]);
				}
				updateUI();

				annotationContainer_element.on("keypress", "input", function(){
					if(keycode == '13') {
						addDiscussion(this);
					}
				})
			});

			//TODO: BIND CLICK EVENTS FOR ANNOTATIONS
		}

		this.newAnnotation = function(point) {
			var name = prompt("Gimme an annotation please");
			if (name!= null && name != ""){
				
				$.post('/model_files/' + sceneID + '/annotations', {"camera": v3ToString(camera.position.clone()), "coordinates": v3ToString(point) , "text": name}, function(data){
					addAnnotation({"text": name, "camera": camera.position.clone(), "coordinates": point, "discussions": []}, data);
					updateUI();
				});
				
			} else{
				return;
			}
		}

		function highlightAnnotation(id) {
			annotationContainer_element.children("li").each(function(){
				if ( getIdWithHtml(this.id) == id) {
					$(this).addClass('active');
				} else {
					$(this).removeClass('active');
				}
			});
			moveCamera(annotations[id].camera);
		}

		function highlightAnnotationWithObj(object){
			highlightAnnotation(getIdWithObj(object));
		}

		this.highlightAnnotationWithIndex = function(element) {
			highlightAnnotation(getIdWithHtml($(element).id));
		}

		this.intersects = function(ray){
			var values = Object.keys(annotation_obj).map(function(key){
    			return annotation_obj[key];
			});
			var intersect = ray.intersectObjects(values);
			if (intersect.length > 0){
				debug("Intersects an annotation");
				highlightAnnotationWithObj(intersect[0].object);
				return true;
			} else {
				return false;
			}
		}


	}

	function intersector(event){
	 	var vector = new THREE.Vector3(
	        ( event.offsetX / scene.width ) * 2 - 1,
	      - ( event.offsetY / scene.height ) * 2 + 1,
	       	.5
	    );
	   	controller.projector.unprojectVector( vector, camera );
	    var ray = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());
	   	ray.precision = 0.001;
	    return ray;
	}

	function viewMouseOver(event){
		moveFlag = 1;
	}

	function viewMouseUp(event){

		if(moveFlag === 0){
			event.preventDefault();
			var ray = intersector(event);
			if (!annot.intersects(ray)){
				if(!model.intersects(ray)) {
					plane.intersects(ray);
				}
			}
		}
	}


	init();

}