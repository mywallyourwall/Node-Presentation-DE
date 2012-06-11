###
	main.js
###



$ ()->

 $body = $ 'body'

 ###
  ===================================================== socket setup
 ###

 if not window.io
  console.error 'socket.io not found'
  return
 sockets = io.connect()

 ###
 	===================================================== index page
 ###

 if $body[0].id is 'index'
  $chat = $ '#chat'
  $log = $ '#log'
  $slides = $ '#slides > li'
  $slideTitle = $ '#slide-title'
  current = 0
  slideCount = $slides.length
  logTimeout = null
  ###
  ===================================================== socket listeners
  ###
  sockets.on 'slide-action', (data) ->
   gotoSlide data.dir

  sockets.on 'receive-chat', (data) -> 
   $p = $ '<p><em>' + data.username + ':</em> ' + data.comment + '</p>'
   $chat.prepend $p
   setTimeout ()->
    $p.addClass 'active'
   , 1000 

  sockets.on 'clear-chat', (data) ->
   $chat.html ''

  sockets.on 'draw-canvas', (data) ->
   $p = $ '<p><em>' + data.username + ':</em><img src="' + data.image + '"></p>'
   console.log '<p><em>' + data.username + ':</em><img src="' + data.image + '"></p>'
   $chat.prepend $p
   setTimeout ()->
    $p.addClass 'active'
   , 1000 

  logIt = (msg)->
   clearTimeout logTimeout
   $log.text(msg).addClass 'active'
   logTimeout = setTimeout ()->
    $log.removeClass 'active'
   , 5000 

  slideTitle = ()->
   $slideTitle.text ': ' + $slides.eq(current).attr 'data-title'

  gotoSlide = (dir)->
   $slides.removeClass 'active'
   if dir is 'next'
    current = if current is slideCount-1 then 0 else current+1
   else
    current = if current is 0 then slideCount-1 else current-1
   logIt current
   $currentSlide = $slides.eq(current)
   slideTitle()
   $currentSlide.addClass 'active'

  $slides.on 'dblclick', ()->
   gotoSlide 'next'

  slideTitle()

 ###
  =====================================================controller page
 ###

 if $body[0].id is 'controller' || $body[0].id is 'chat-page'
  $comment = $ '#comment'
  $name = $ '#name'
  $('form#controller-form').submit (e)->
   e.preventDefault()

  $('a#next').click (e)->
   e.preventDefault()
   msg = 
    dir : 'next'
   sockets.emit 'slide', msg

  $('a#prev').click (e)->
   e.preventDefault()
   msg = 
    dir : 'prev'
   sockets.emit 'slide', msg

  $('a#send-comment').click (e)->
   e.preventDefault()
   comment = $.trim $comment.val()
   if comment is ''
    return false
   username = $.trim $name.val()
   username = if username is '' then 'Eine Memme' else username
   msg = 
    'comment' : comment
    'username' : username
   sockets.emit 'send-chat', msg
   $comment.val('')
 
  $('a#reset-comment').click (e)->
   e.preventDefault()
   msg = 
    reset : true
   sockets.emit 'reset-chat', msg

 if $body[0].id is 'chat-page'
      `var cb_canvas = null,
      cb_ctx = null,
      cb_lastPoints = null;


      function init(e) {
        cb_canvas = document.getElementById("cb_canvas");

        cb_lastPoints = Array();

        if (cb_canvas.getContext) {
          cb_ctx = cb_canvas.getContext('2d');
          cb_ctx.lineWidth = 5;
          cb_ctx.strokeStyle = "#33ff00";
          cb_ctx.beginPath();

          cb_canvas.onmousedown = startDraw;
          cb_canvas.onmouseup = stopDraw;
          cb_canvas.ontouchstart = startDraw;
          cb_canvas.ontouchstop = stopDraw;
          cb_canvas.ontouchmove = drawMouse;
        }
      };

      function startDraw(e) {
        if (e.touches) {
          // Touch event
          for (var i = 1; i <= e.touches.length; i++) {
            cb_lastPoints[i] = getCoords(e.touches[i - 1]); // Get info for finger #1
          }
        }
        else {
          // Mouse event
          cb_lastPoints[0] = getCoords(e);
          cb_canvas.onmousemove = drawMouse;
        }
        
        return false;
      }

      // Called whenever cursor position changes after drawing has started
      function stopDraw(e) {
        e.preventDefault();
        cb_canvas.onmousemove = null;
      };

      function drawMouse(e) {
        if (e.touches) {
          // Touch Enabled
          for (var i = 1; i <= e.touches.length; i++) {
            var p = getCoords(e.touches[i - 1]); // Get info for finger i
            cb_lastPoints[i] = drawLine(cb_lastPoints[i].x, cb_lastPoints[i].y, p.x, p.y);
          }
        } else {
          // Not touch enabled
          var p = getCoords(e);
          cb_lastPoints[0] = drawLine(cb_lastPoints[0].x, cb_lastPoints[0].y, p.x, p.y);
        }
        cb_ctx.stroke();
        cb_ctx.closePath();
        cb_ctx.beginPath();

        return false;
      };

      // Draw a line on the canvas from (s)tart to (e)nd
      function drawLine(sX, sY, eX, eY) {
        cb_ctx.moveTo(sX, sY);
        cb_ctx.lineTo(eX, eY);
        return { x: eX, y: eY };
      };

      // Get the coordinates for a mouse or touch event
      function getCoords(e) {
        return { x: e.pageX - cb_canvas.offsetLeft, y: e.pageY - cb_canvas.offsetTop };
      };

      function reset(){
          cb_canvas.width = cb_canvas.width;
          cb_ctx.lineWidth = 5;
          cb_ctx.strokeStyle = "#33ff00";
      };

      $('#clear-canvas').click(function(e) {
        e.preventDefault();
        reset();
        return true;
      });
      $('a#send-canvas').click(function(e) {
          var canvasData, msg, username, _encode;
          e.preventDefault();
          canvasData = cb_canvas.toDataURL('image/jpeg');
          username = $.trim($name.val());
          username = username === '' ? 'Eine Memme' : username;
          username = username + ' malt';
          msg = {
            'username': username,
            image: canvasData
          };
          reset();
          return sockets.emit('canvas', msg);        
      });

      init();`

 @ 