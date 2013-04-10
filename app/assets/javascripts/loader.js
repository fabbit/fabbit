/**
 * @author aleeper / http://adamleeper.com/
 * @author mrdoob / http://mrdoob.com/
 *
 * Description: A THREE loader for STL ASCII files, as created by Solidworks and other CAD programs.
 *
 * Supports both binary and ASCII encoded files, with automatic detection of type.
 *
 * Limitations: Binary decoding ignores header. There doesn't seem to be much of a use for it.
 *        There is perhaps some question as to how valid it is to always assume little-endian-ness.
 *        ASCII decoding assumes file is UTF-8. Seems to work for the examples...
 *
 * Usage:
 *  var loader = new THREE.STLLoader();
 *  loader.addEventListener( 'load', function ( event ) {
 *
 *    var geometry = event.content;
 *    scene.add( new THREE.Mesh( geometry ) );
 *
 *  } );
 *  loader.load( './models/stl/slotted_disk.stl' );
 */


THREE.STLLoader = function () {

  THREE.EventDispatcher.call( this );

};

THREE.STLLoader.prototype = {

  constructor: THREE.STLLoader,


  load: function ( url, isString) {

    var scope = this;
    var isString = (typeof isString === 'undefined') ? false: isString; //if isString is not passed, assume false!

    if (isString){

      url = url.trim();
      var g = scope.parse(url);
      scope.dispatchEvent({type: 'load', content: g});

    } else {
      
      //if its not a string then load it the regular way
      var request = new XMLHttpRequest();
      request.addEventListener( 'load', function ( event ) {

        var geometry;
        geometry = scope.parse( event.target.response);

        scope.dispatchEvent( { type: 'load', content: geometry } );

      }, false );

      request.addEventListener( 'progress', function ( event ) {

        scope.dispatchEvent( { type: 'progress', loaded: event.loaded, total: event.total } );

      }, false );

      request.addEventListener( 'error', function () {

        scope.dispatchEvent( { type: 'error', message: 'Couldn\'t load URL [' + url + ']' } );
      }, false );

      
      request.open( 'GET', url, true );
      request.overrideMimeType('text/plain; charset=x-user-defined');
      request.send( null );

    }
  },

  bin2str: function (buf) {

    if (typeof(buf) === 'string') {
      return buf;
    }
    var array_buffer = new Uint8Array(buf);
    var str = '';
    for(var i = 0; i < buf.byteLength; i++) {
      str += String.fromCharCode(array_buffer[i]); // implicitly assumes little-endian
    }
    return str

  },

  isASCII: function(buf){
    
    if (typeof(buf) === 'string'){
      var str = buf.substring(0,5);
    } else {
      var dv = new DataView(buf);
      var str = '';
      for(var i = 0; i < 10; i++) {
        str += String.fromCharCode(dv.getUint8(i, true)); // assume little-endian
      }
    }
    var ret = str.indexOf("solid") >= 0;
    console.log("returning " + ret);
    return false;
  },

  parse: function (buf) {

    if(this.isASCII(buf))
    {
      var str = this.bin2str(buf);
      return this.parseASCII(str);
    }
    else
    {
      return this.parseBinaryFile(buf);
    }

  },

  parseASCII: function ( data ) {

    var geometry = new THREE.Geometry();

    var patternFace = /facet([\s\S]*?)endfacet/g;
    var result;

    while ( ( result = patternFace.exec( data ) ) != null ) {
      var text = result[ 0 ];

      // Normal
      var patternNormal = /normal[\s]+([-+]?[0-9]+\.?[0-9]*([eE][-+]?[0-9]+)?)+[\s]+([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+[\s]+([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+/g;

      while ( ( result = patternNormal.exec( text ) ) != null ) {

        var normal = new THREE.Vector3( parseFloat( result[ 1 ] ), parseFloat( result[ 3 ] ), parseFloat( result[ 5 ] ) );

      }

      // Vertex
      var patternVertex = /vertex[\s]+([-+]?[0-9]+\.?[0-9]*([eE][-+]?[0-9]+)?)+[\s]+([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+[\s]+([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+/g;

      while ( ( result = patternVertex.exec( text ) ) != null ) {

        geometry.vertices.push( new THREE.Vector3( parseFloat( result[ 1 ] ), parseFloat( result[ 3 ] ), parseFloat( result[ 5 ] ) ) );

      }

      var len = geometry.vertices.length;
      geometry.faces.push( new THREE.Face3( len - 3, len - 2, len - 1, normal ) );

    }

    geometry.computeCentroids();
    geometry.computeBoundingSphere();
    return geometry;

  },

  parseBinaryFile: function(input) {
 
    input = new BinaryReader(input);

    // Skip the header.
    input.seek(80);

    var geometry = new THREE.Geometry();
    // Load the number of vertices.
    var count = input.readUInt32();

    // During the parse loop we maintain the following data structures:
    var vertices = [];   // Append-only list of all unique vertices.
    var vert_hash = {};  // Mapping from vertex to index in 'vertices', above.
    var faces    = [];   // List of triangle descriptions, each a three-element
                         // list of indices in 'vertices', above.


    for (var i = 0; i < count; i++) {
      if (i % 100 == 0) {
        //console.log('Parsing ' + (i+1) + ' of ' + count + ' polygons...');
      }
      
      // Skip the normal (3 single-precision floats)
      input.seek(input.getPosition() + 12);

      var face_indices = [];
      for (var x = 0; x < 3; x++) {
        var vertex = [input.readFloat(), input.readFloat(), input.readFloat()];
       
        var vertexIndex = vert_hash[vertex];
        if (vertexIndex == null) {
          vertexIndex = vertices.length;
          vertices.push(vertex);
          vert_hash[vertex] = vertexIndex;
        }

        face_indices.push(vertexIndex);
      }
      faces.push(face_indices);

      // Skip the "attribute" field (unused in common models)
      input.readUInt16();
    }

    for (var i=0; i<faces.length; i++){
      geometry.faces.push(new THREE.Face3(faces[i][0], faces[i][1], faces[i][2]));
    }
    for (var i=0; i<vertices.length; i++){
      geometry.vertices.push(new THREE.Vector3(vertices[i][0], vertices[i][1], vertices[i][2]));
    }


    geometry.computeBoundingSphere();
    geometry.computeCentroids();
    geometry.computeFaceNormals();

    return geometry;
  },

  parseBinary: function (buf) {

    // STL binary format specification, as per http://en.wikipedia.org/wiki/STL_(file_format)
    //
    // UINT8[80] – Header
    // UINT32 – Number of triangles
    //
    // foreach triangle
    //   REAL32[3] – Normal vector
    //   REAL32[3] – Vertex 1
    //   REAL32[3] – Vertex 2
    //   REAL32[3] – Vertex 3
    //   UINT16 – Attribute byte count
    // end
    //

    function str2ab(str) {
      var buf = new ArrayBuffer(str.length*2); // 2 bytes for each char
      var bufView = new Uint16Array(buf);
      for (var i=0, strLen=str.length; i<strLen; i++) {
        bufView[i] = str.charCodeAt(i);
      }
      return buf;
    }


    var geometry = new THREE.Geometry();

    var headerLength = 80;
    var dataOffset = 84;
    var faceLength = 12*4 + 2;

    var le = true; // is little-endian  // This might be processor dependent...

    // var header = new Uint8Array(buf, 0, headerLength); // not presently used
    if (typeof(buf) === 'string') {
      buf = str2ab(buf);
    }

    var dvTriangleCount = new DataView(buf, headerLength, 4);

    var numTriangles = dvTriangleCount.getUint32(0, le);

    for (var i = 0; i < numTriangles; i++) {

      //console.log(dataOffset + i*faceLength, faceLength);
      
      //console.log(dataOffset + i*faceLength + " " + faceLength);
      var dv = new DataView(buf, dataOffset + i*faceLength, faceLength);

      var normal = new THREE.Vector3( dv.getFloat32(0, le), dv.getFloat32(4, le), dv.getFloat32(8, le) );

      for(var v = 3; v < 12; v+=3) {
        var v = new THREE.Vector3( dv.getFloat32(v*4, le), dv.getFloat32((v+1)*4, le), dv.getFloat32( (v+2)*4, le ) );
        //console.log(v);
        geometry.vertices.push(v);

      }
      var len = geometry.vertices.length;
      geometry.faces.push( new THREE.Face3( len - 3, len - 2, len - 1, normal ) );
    }

    geometry.computeCentroids();
    geometry.computeBoundingSphere();

    return geometry;
  }

};