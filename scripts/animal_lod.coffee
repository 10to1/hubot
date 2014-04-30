# Description:
#   When hubot hears someone call for an `animal lod`, it will show one.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   animal lod - Display a picture of an angry animal
#
# Author:
#   pjaspers

lods = ["http://www.sadanduseless.com/wp-content/uploads/2014/04/angry1.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry2.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry3.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry4.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry5.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry6.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry7.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry8.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry9.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry10.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry11.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry12.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry13.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry14.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry15.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry16.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry17.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry18.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry19.jpg",
"http://www.sadanduseless.com/wp-content/uploads/2014/04/angry20.jpg"]

module.exports = (robot) ->
  robot.hear /animal lod/i, (msg) ->
    msg.send msg.random lods