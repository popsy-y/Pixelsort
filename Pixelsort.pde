import processing.video.*;

int STL = 0, SEQ = 1, CAP = 2;
int mode = CAP;

// STILL IMAGE
// variable for still image
PImage img;


// IMAGE SEQUENCE
// variable for image sequence
PImage[] seq;

// length of image sequence
int seqLen = 83;

int targetFps = 10;

boolean showProcessTime = true;


// CAMERA CAPTURE
String[] devices = Capture.list();
Capture input;


int canvSize = 800;
int pad, imgLongSide;

int HUE = 0, SAT = 1, BRI = 2;
int HOR = 0, VER = 1;

void settings(){
	size(canvSize, canvSize);
}

void setup() {
	frameRate(targetFps);

	colorMode(HSB, 360, 100, 100);

	if (showProcessTime) {
		textSize(16);
		fill(0, 0, 80);
	}

	switch (mode) {
		case 0:
			break;
		case 1:
			seq = new PImage[seqLen];

			for (int i = 0; i < seqLen; ++i) {
				seq[i] = loadImage("seq/" + i + ".png");
				println("Loading... " + (i + 1) + " / " + seqLen);
			}

			return;
		case 2:
			while(devices.length == 0){
				devices = Capture.list();
			}

			for (String dev : devices) {
				println(dev);
			}

			if (devices.length > 0) {
				input = new Capture(this, devices[0]);
				input.start();

				return;
			}else{
				println("NO AVAILABLE INPUT DEVICES.");
				exit();
			}
		default:
			println("INVALID MODE INTEGER. 0: still, 1: sequence, 2: capture");
			return;
	}


	//  APPLY TO STILL IMAGE
	// -------------------------------
	img = loadImage("photo.png");

	showFittedImage(img, 0);

	loadPixels();

	// doSort
	// arguments:
	// - mask mode (int, you can use: (HUE, SAT, BRI))
	// - mask lower threshold (int)
	// - mask higher threshold (int)
	// - sort direction (int, you can use: (HOR, VER))
	// - invert sort result (bool)
	// - sort target (int, you can use: (HUE, SAT, BRI))
	doSort(HUE, 80, 150, HOR, false, BRI);
	doSort(BRI, 45, 100, VER, true, BRI);
	doSort(BRI, 45, 100, HOR, false, SAT);
	doSort(BRI, 52, 90, VER, false, BRI);

	// or you can use sortStack()
	// sortStack();

	// uncomment to check mask :)
	// showMask(BRI, 52, 90);

	updatePixels();
}

void draw(){
	int frameStart = millis();

	if (keyPressed && (key == 'S' || key == 's')) {
		java.util.Date d = new java.util.Date();
		save("save" + d.getTime() + ".png");
	}


	switch (mode) {
		case 0:
			return;
		case 1:
			showFittedImage(seq[frameCount % seq.length], 0);
			break;
		case 2:
			if (input.available()) {
				input.read();
				showFittedImage(input, 0);
			}

			break;
		default:
			println("INVALID MODE INTEGER. 0: still, 1: sequence, 2: capture");
			return;
	}


	int sortStart = millis();

	loadPixels();
	
	sortStack();

	updatePixels();

	if (showProcessTime) {
		text("frm: " + (millis() - frameStart) + "ms", 20, 30);
		text("srt: " + (millis() - sortStart) + "ms", 20, 50);
	}
}

void sortStack(){
	int start = millis();

	doSortHush(BRI, 40, 100, VER, false, BRI);
	doSortHush(HUE, 170, 220, HOR, false, BRI);

	if (millis() - start > 1000 / targetFps) {
		println("[WARN] Delayed! Time took: " + (millis() - start) + "msec(s), Budget: " + (1000 / targetFps) + "msec(s)");
	}
}

void showFittedImage(PImage img, int pad){
	imgLongSide = canvSize - (pad * 2);


	boolean isWidthLonger = img.width >= img.height;

	float ratio = isWidthLonger ? (float) img.height / img.width : (float) img.width / img.height;

	int imgW = isWidthLonger ? imgLongSide : round(imgLongSide * ratio);
	int imgH = isWidthLonger ? round(imgLongSide * ratio) : imgLongSide;

	int px = isWidthLonger ? pad : (width - imgW) / 2;
	int py = isWidthLonger ? (height - imgH) / 2 : pad;

	img.resize(imgW, imgH);

	background(0);
	image(img, px, py);
}


void doSort(int maskMode, int threshLow, int threshHigh, int direction, boolean invert, int sortBy){
	int started = millis();

	boolean[] mask = makeMask(maskMode, threshLow, threshHigh);
	apply(mask, direction, invert, sortBy);
	println("Sorted. Time took: " + (millis() - started) + " msec(s).");
}

void doSortHush(int maskMode, int threshLow, int threshHigh, int direction, boolean invert, int sortBy){
	boolean[] mask = makeMask(maskMode, threshLow, threshHigh);
	apply(mask, direction, invert, sortBy);
}

void showMask(int maskMode, int threshLow, int threshHigh){
	int started = millis();

	boolean[] mask = makeMask(maskMode, threshLow, threshHigh);
	int idx = 0;
	for (boolean pix : mask) {
		pixels[idx] = pix ? color(0, 0, 100) : color(0);
		idx++;		
	}
	println("Mask drawn. Time took: " + (millis() - started) + " msec(s).");
}

void showMaskHush(int maskMode, int threshLow, int threshHigh){
	boolean[] mask = makeMask(maskMode, threshLow, threshHigh);
	int idx = 0;
	for (boolean pix : mask) {
		pixels[idx] = pix ? color(0, 0, 100) : color(0);
		idx++;		
	}
}

boolean[] makeMask(int mode, int threshLow, int threshHigh){
	boolean[] mask = new boolean[pixels.length];

	int i = 0;

	for (color pix : pixels) {
		switch (mode) {
			case 0:
				if (hue(pix) > threshLow && hue(pix) < threshHigh) {
					mask[i] = true;
				}else{
					mask[i] = false;
				}
				break;
			case 1:
				if (saturation(pix) > threshLow && saturation(pix) < threshHigh) {
					mask[i] = true;
				}else{
					mask[i] = false;
				}
				break;
			case 2:
				if (brightness(pix) > threshLow && brightness(pix) < threshHigh) {
					mask[i] = true;
				}else{
					mask[i] = false;
				}
				break;
			default :
				println("ERR: Invalid mode integer. 0: luminance, 1: saturation, 2: hue");
				break;	
		}

		i++;
	}


	return mask;
}