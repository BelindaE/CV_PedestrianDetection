vid = videoinput('winvideo', 1, 'RGB24_640x480');
vid.FramesPerTrigger = 1;
preview(vid);