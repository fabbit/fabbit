// modelViewer = function(sceneContainer, uniqueID) {

// 	var scene;
// 	var sceneID = uniqueID;
// 	var sceneElement = $(sceneContainer);

// 	var objects;
// 	var camera;
// 	var renderer;

// 	function animate() {
// 		requestAnimationFrame(animate);
// 		//TODO: controls.update();
// 		//TODO: UPDATE TWEEN!
// 		renderer.render(scene, camera)
// 	}

// 	function init(){

// 		objects = [];

// 		//Set up scene
// 		scene = { "width": 800, "height": 450, "scene": new THREE.Scene()};	
// 		camera = new THREE.PerspectiveCamera(45, 1.77, .1, 100); //view_angle, aspect = width/height, near, far
// 		scene.scene.add(camera);

// 		//create and append renderer to sceneElement
// 		renderer = new THREE.WebGLRenderer();
// 		renderer.setSize(scene.width, scene.height);
// 		sceneElement.append(render.domElement);

// 		//TODO: ADD EVENT LISTENERS!!!

// 		//TODO: ADD CONTROLS

// 		//Add lighting!
// 		var pointLight1 = new THREE.PointLight(0xFFFFFF);
// 		pointLight1.position = new THREE.Vector3(40,50,130);
// 		scene.add(pointLight1);
// 		var pointLight2 = new THREE.PointLight(0xFFFFFF);
// 		pointLight2.position = new THREE.Vector3(-40,-50,-130);
// 		scene.add(pointLight2);

// 		//Add plane!
// 		var planeMat = new THREE.MeshBasicMaterial({color: 0xFFAF96, wireframe:true, transparent: true});
// 		planeMat.opacity = 0.3;
// 		plane = new THREE.Mesh( new THREE.PlaneGeometry(100, 100, 10,10), planeMat);
// 		objects.push(plane);
// 		scene.add(plane);
		
// 		//TODO: ADD ANNOTATIONS!

// 		animate();
// 	}

// 	//CLASS MODEL
// 	model = function(fileName, statusElement){

// 		var file = fileName;
// 		var loaderStatus_element = $(statusElement);

// 		var objectColor = "#C0D8F0";

// 		//model.loadModel()
// 		this.loadModel = function() {
			
// 			var loader = new THREE.STLLoader();
// 			$(loaderStatus_element).html("Loading element");
			
// 			loader.addEventListener( 'load', function ( event ) {
				
// 				var geometry = event.content;
// 				$(loaderStatus_element).html("Loaded element </br> s to zoom, a to pan");

// 				//Create material and mesh
// 				var material = new THREE.MeshLambertMaterial({color:objectColor, shading: THREE.FlatShading});
// 				var mesh = new THREE.Mesh( geometry, material );
// 				mesh.position.set( 0, - 0.25, 0.6 ); //TODO: Calculate position and rotation better
// 				mesh.rotation.set( 0, - Math.PI / 2, 0 );
				
// 				var boundedBy = mesh.geometry.boundingSphere.radius;
// 				var scaleFactor = 25/boundedBy;			
// 				mesh.scale.set(scaleFactor, scaleFactor, scaleFactor);
				
// 				objects.push(mesh); //TODO: Do we need this anymore? For plane and stuff
// 				scene.add(mesh);
// 				return mesh;

// 			});

// 			loader.load(this.fileName);

// 		} //Close loadModel

// 		this.setColor = function(color) {
// 			objectColor = color;
// 		}

// 	}

// 	this.addModel = function(fileName){
// 		var objectModel = new model(fileName);
// 		objects.add(objectModel.load());
// 		//objectModel.setColor("#eeee")
// 	}





// }