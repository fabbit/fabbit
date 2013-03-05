var WIDTH, HEIGHT;
			var VIEW_ANGLE, ASPECT, NEAR, FAR;
			var renderer, camera, scene;
			var projector;
			var controls;
			var objects = [];
			var annot_obj = [];
			var annot_camera = [];
			var annot_text = [];
			var currentlyactive = 0;
			var tween;
			var objectColor = "#C0D8F0";

			function v3(a,b,c){
				return new THREE.Vector3(a,b,c);
			}

			function startThis(stri){
                        	init();
				positionCamera(v3(0,0,100));
				drawPlane();
				addLight();
				animate();

				var stlString = stri;

				//set up the loader and load in an object. 
				var loader = new THREE.STLLoader();
				$("#loader_status").html("LOADING ELEMENT");
				loader.addEventListener( 'load', function ( event ) {
     				
     				var geometry = event.content;
     				$("#loader_status").html("LOADED ELEMENT");

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
  				loader.load(stlString,false,true);
			}
			

			function positionCamera(pos) {
				
				var earlypos = { x : camera.position.x, y: camera.position.y, z: camera.position.z };
				
				//to make the movement smooth
				tween = new TWEEN.Tween(earlypos).to(pos, 1000);
				tween.onUpdate(function(){
				    camera.position.x = earlypos.x;
				    camera.position.y = earlypos.y;
				    camera.position.z = earlypos.z;
				});
				tween.start();

				//always look at center! (or where object is)
				camera.lookAt(new THREE.Vector3(0,0,0));
				camera.updateMatrix();
			}

			function init() {

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
				renderer.domElement.addEventListener('mousedown', viewMouseDown,     false);

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
				
				$(container).append(renderer.domElement);
			}

			function drawPlane(){
				plane = new THREE.Mesh( new THREE.PlaneGeometry(100, 100, 10,10), new THREE.MeshBasicMaterial({color:0xafafaf,wireframe:true}));
				objects.push(plane);
    			scene.add(plane);
			}

			function drawSphere(pos){
				
				pos = typeof pos !== 'undefined' ? pos: new THREE.Vector3(0,0,0);
  			
			
				var objectColor = 0x0066FF;
				    // create the sphere's material
				var sphereMaterial =  new THREE.MeshLambertMaterial({ color: objectColor, shading: THREE.FlatShading });
				// create a new mesh with
				// sphere geometry - we will cover
				// the sphereMaterial next!
				var sphere = new THREE.Mesh(

				  new THREE.SphereGeometry(
				    5, //radius
				    100, //segments
				    100), //rings
				  sphereMaterial);

				sphere.position = pos;
				var name=prompt("Please enter an annotation","");
				if (name!=null && name!="")
  				{
  					// add the sphere to the scene
					annot_obj.push(sphere);
					annot_camera.push(camera.position.clone()); //TODO: make sure that there is actually a camera position
					annot_text.push(name);
					$("#annotation_list").append("<li>" + name + "</li>");
					scene.add(sphere);
  				}
			}

			function addLight(){
				// create a point light
				var pointLight1 =
				  new THREE.PointLight(0xFFFFFF);

				// set its position
				pointLight1.position.x = 10;
				pointLight1.position.y = 50;
				pointLight1.position.z = 130;

				// add to the scene
				scene.add(pointLight1);

				var pointLight2 =
				  new THREE.PointLight(0xFFFFFF);

				// set its position
				pointLight2.position.x = 10;
				pointLight2.position.y = 50;
				pointLight2.position.z = -130;

				// add to the scene
				scene.add(pointLight2);
			}

			function animate() {

				requestAnimationFrame( animate );

				controls.update();
				render();

			}

			function render() {
				TWEEN.update();
				renderer.render(scene,camera);
			}

			//deals with clicks => annotations. annotations basically are spheres at this point
			function viewMouseDown(event){
				event.preventDefault();

			    var vector = new THREE.Vector3(
			        ( event.clientX / WIDTH ) * 2 - 1,
			      - ( event.clientY / HEIGHT ) * 2 + 1,
			       	.5
			    );

			   	projector.unprojectVector( vector, camera );

			    var ray = new THREE.Raycaster(camera.position, vector.sub(camera.position).normalize());

			    var intersects_annots = ray.intersectObjects(annot_obj);
			    var intersects_objects = ray.intersectObjects(objects);

			    if (intersects_annots.length > 0 ){
			    	
			    	console.log(intersects_annots[0]);
			    	var pos = annot_obj.indexOf(intersects_annots[0].object);

			    	positionCamera(annot_camera[pos]);

			    	
			    	var annotation_selector = "#annotations ul li:nth-child(" + (currentlyactive  + 1 )+ ")";
			    	console.log($(annotation_selector));

			    	$(annotation_selector).removeClass("active");

			    	currentlyactive = pos;

			    	annotation_selector =  "#annotations ul li:nth-child(" + (currentlyactive + 1) + ")";
			    	$(annotation_selector).addClass("active");
			    	
			    } 
			    else if (intersects_objects.length > 0){
			    	drawSphere(intersects_objects[0].point);
			    }

			}
