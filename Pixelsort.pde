PImage img;

int canvSize = 800;
int pad, imgLongSide;

int HUE = 0, SAT = 1, BRI = 2;
int HOR = 0, VER = 1;

void settings(){
	size(canvSize, canvSize);
}

void setup() {
	colorMode(HSB, 360, 100, 100);

	img = loadImage("photo.png");
	pad = 0;
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

	// uncomment to check mask :)
	// showMask(BRI, 52, 90);

	updatePixels();
}


void doSort(int maskMode, int threshLow, int threshHigh, int direction, boolean invert, int sortBy){
	int started = millis();

	boolean[] mask = makeMask(maskMode, threshLow, threshHigh);
	apply(mask, direction, invert, sortBy);
	println("Sorted. Time took: " + (millis() - started) + " msec(s).");
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