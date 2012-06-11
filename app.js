
/* ramon nodejs example 2012 */


/* ===================================================== load modules */
var express = require('express'),
app = module.exports = express.createServer(),
io = require('socket.io');


/* ===================================================== heroku doesn't support websockets yet */
app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(require('stylus').middleware({ src: __dirname + '/public' }));
  app.use(express.compiler({
    src: __dirname + '/src',
    dest: __dirname + '/public',
    enable: ['coffeescript']
  }));  
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});


/* ===================================================== start server - Only listen on command: $ node app.js*/
if (!module.parent) {
  var port = process.env.PORT || 3000;
  app.listen(port, function() {
    console.log("Express server listening on port %d", port);
  });
}


/* ===================================================== routing */
app.get('/', function(request, response) {

  response.render('index.jade', {
    locals: { 
      title : 'Eine Einführung in Node.js',
      pageid : 'index'
    }
  });

});


app.get('/controller', function(request, response) {
  response.render('controller.jade', {
    locals: { 
      title : 'Controller',
      pageid : 'controller' 
    }
  });
});

app.get('/chat', function(request, response) {
  response.render('chat.jade', {
    locals: { 
      title : 'Chat',
      pageid : 'chat-page' 
    }
  });
});


/* ===================================================== socket listeners */

var sio = io.listen(app);

/* ===================================================== heroku doesn't support websockets yet */
sio.configure(function () { 
  sio.set("transports", ["xhr-polling"]); 
  sio.set("polling duration", 10); 
});

 
sio.sockets.on('connection', function (socket) {
    console.log('A socket connected!');
    socket.on('slide', function (data) {
      socket.broadcast.emit('slide-action', data);
    });

    socket.on('send-chat', function (data) {
      socket.broadcast.emit('receive-chat', data);
    });

    socket.on('reset-chat', function (data) {
      socket.broadcast.emit('clear-chat', data);
    });

    socket.on('canvas', function (data) {
      socket.broadcast.emit('draw-canvas', data);
    });

});

