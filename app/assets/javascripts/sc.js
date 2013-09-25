modelViewer = function(sceneContainer, uniqueID, memberID, annotationUI) {

	//Essentials
	var camera;
	var renderer;
	var controller;

	//Scene variables
	var scene;
	var sceneID = uniqueID;
        var memberID = memberID;
	var sceneElement = $(sceneContainer);

	//Intersection variables
	var plane;
	var model;
	var annot;

	//Camera tween
	var tween;

	//Me
	var me = this;

	/* HELPER FUNCTIONS */
	function debug(str){
		if(true){
			console.log(str);
		}
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
			if (typeof s[0] == "string")
				return new THREE.Vector3(parseFloat(s[0]), parseFloat(s[1]), parseFloat(s[2]));
			else 
				return new THREE.Vector3(s[0], s[1], s[2]);
		}
	}

	/* PRIVATE FUNCTIONS */
	function animate() {
		requestAnimationFrame(animate);
		controller.controls.update();
		TWEEN.update();
		renderer.render(scene.scene, camera);
	}

	function moveCamera(newPosition) {
		//camera.position = newPosition;

		var oldpos = {x: camera.position.x, y: camera.position.y, z: camera.position.z};

		tween = new TWEEN.Tween(oldpos).to(newPosition, 500);
		tween.onUpdate(function(){
			camera.position.x = oldpos.x; camera.position.y = oldpos.y; camera.position.z = oldpos.z;
		});
		tween.start();

		camera.lookAt(new THREE.Vector3(0,0,0));
		camera.updateMatrix();
	}

	
	function init(){
		
		objects = [];
		//Set up scene
		scene = { "width": 845, "height": 480, "scene": new THREE.Scene()};	
		camera = new THREE.PerspectiveCamera(45, 1.77, scene.width /scene.height, 10000); //view_angle, aspect = width/height, near, far
		moveCamera(new THREE.Vector3(0,0,100));
		scene.scene.add(camera);

		//create and append renderer to sceneElement
		renderer = new THREE.WebGLRenderer();
		renderer.setSize(scene.width, scene.height);
		sceneElement.append(renderer.domElement);
		debug("Added renderer to dom");

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
		debug("Added lighting to scene");

		//Add plane!
		plane = new Plane();

		//Have a variable around for annotation functions
		annot = new Annotations();
		
		animate();
		
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
			var intersect_response = annot.intersects(ray);
			if (intersect_response) {
				//Highlight the right annotation
				me.highlightAnnotation(intersect_response);
				annotationUI.highlightAnnotation(intersect_response);
				return;
			} 

			intersect_response = model.intersects(ray);
			if (intersect_response) {
				//Add a new annotation on the point
				postAnnotation(intersect_response);
				return;
			} 

			intersect_response = plane.intersects(ray);
			if (intersect_response) {
				//Add a new annotation on the point
				postAnnotation(intersect_response);
				return;
			} 
		}
	}	

	function postAnnotation(point){
		var name;
		name = prompt("Please enter a title for this annotation:");
		debug("Annotation name is " + name);
		if (name === null || name === ""){
			//BTODO: ERROR!?
		} else {

			console.log("POST ANNOTATION AT " + point);
			$.post('/versions/' + sceneID + '/annotations', {"camera": v3ToString(camera.position.clone()), "coordinates": v3ToString(point) , "text": name}, function(data){
				//Do nothing on success
			});
		}
	}

	/* DATA MODELS/CLASSES */

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
				return intersect[0].point;
			} else {
				return false;
			}
		}

		createPlane();
	}

	//CLASS MODEL
	Model = function(fileName, statusElement){

		var file = fileName;
		var loaderStatus_element = $("#loader_status"); //todo: make this better!

		var objectColor = "#C0D8F0";
		var object;

		//model.loadModel()
		this.load = function() {
			
			var loader = new THREE.STLLoader();
			$(loaderStatus_element).html("Loading element");
			
			loader.addEventListener( 'load', function ( event ) {
				
				var geometry = event.content;
				$(loaderStatus_element).html("s to zoom, d to pan");

				//Create material and mesh
				var material = new THREE.MeshLambertMaterial({color:objectColor, shading: THREE.FlatShading});
				var mesh = new THREE.Mesh( geometry, material );				
				var boundedBy = mesh.geometry.boundingSphere.radius;
				var scaleFactor = 25/boundedBy;			

				//Move the mesh around
				mesh.position.set(0 ,0,0); //TODO: Calculate position and rotation better
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
				return intersect[0].point;
			} else {
				return false;
			}
		}
	}

	this.addModel = function(fileName){
		model = new Model(fileName);
		model.load();
	}

	//ANNOTATIONS
	Annotations = function() {
		

		var annotations = {}  //annotations[id] = [data in json,  actual object]
		var obj_to_id = [[],[]]; //two arrays, one for id one for object
		var annotColor =  "#3079ed";
		var viewAnnots = true;


		/* HELPER FUNCTIONS */

		//Create a mapping between an object and its id (for click events)
		function createMap(id, object) {
			obj_to_id[0].unshift(object);
			obj_to_id[1].unshift(id);
		}

		//Get an ID based on the actual 3d object that was clicked
		function getIdWithObj(object){
			return obj_to_id[1][obj_to_id[0].indexOf(object)]; 
		}

		/* ACTUAL FUNCTIONS */
		//The register annotation function takes an id and position data (camera,point) and adds an actual annotation object to the viewer for it
		this.newAnnotation = function(id, camera, point) {
			annotations[id] =  [];
			annotations[id][0] = {"camera": camera, "point": point}; //Register the data for the annotation

			var sphereMaterial = new THREE.MeshBasicMaterial({ color: annotColor, transparent: true});
			sphereMaterial.opacity = 0.6;
			var sphere = new THREE.Mesh(
			  new THREE.SphereGeometry(
			    3, //radius
			    100, //segments
			    100), //rings
			  sphereMaterial);
			createMap(id, sphere);
			sphere.position = point;
			if (viewAnnots){ //TODO : could be less jank
				scene.scene.add(sphere);
			}

			annotations[id][1] = sphere;  //Register the actual object for the annotation
			createMap(id,sphere);
		}
		
		//Actually move the camera to the right annotation
		this.viewAnnotation = function(id) {
			moveCamera(annotations[id][0].camera);
		}

		//Intersection checking for annotations (returns id of actual object that was intersected)
		this.intersects = function(ray){
			var spheres =  obj_to_id[0];
			var intersect = ray.intersectObjects(spheres);
			if (intersect.length > 0){
				debug("Intersects annotation");
				return getIdWithObj(intersect[0].object);
			} else {
				return false;
			}
		}
		//Turn annotations off and on
		this.toggleAnnotationView = function(){
			viewAnnots = !viewAnnots;
			for (var i = 0; i < obj_to_id[0].length; i++){
				var obj = obj_to_id[0][i];
				if (viewAnnots)	{scene.scene.add(obj);}
				else  { scene.scene.remove(obj); }
			}
		}
	}

	//Simply just look at a specific annotation referenced by id
	this.highlightAnnotation = function(id) {
		annot.viewAnnotation(id);
	}

	//Accepts id, data (data should be in the form of {camera, coordinates})
	this.registerAnnotation = function(id, data){
		//TODO: ADD ERROR CHECKING FOR THIS!
		annot.newAnnotation(id, stringToV3(data.camera), stringToV3(data.coordinates));
	}

	this.toggleAnnotations = function() {
		annot.toggleAnnotationView();
		animate();
	}

	this.initialize = function() {
		init(); //Auto call to init viewer
	}
}
