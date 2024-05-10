void apply(boolean[] mask, int direction, boolean invert, int sortBy){
	int length0, length1;

	if (direction == HOR) {
		length0 = width;
		length1 = height;
	}else {
		length0 = height;
		length1 = width;
	}

	for (int i = 0; i < length0; ++i) {
		for (int j = 0; j < length1; ++j) {

			// array to store sorted pixel array
			color[] sorted;

			// length of pixel array
			int k = 0;

			// index of sort target group's head
			int start = 0;


			if (direction == HOR)
			{
				//  HORIZONTAL SORTING
				// -----------------------------

				// i = row, j = col

				// #row * imgWidth + #col
				start = i * length0 + j;


				// skip if mask is false(black)
				if (!mask[start]) { continue; }

				// next mask pixel is true(white) && next mask pixel is not a right end
				while (mask[start + k] && (j + k) % width != 0) {
					k++;

					// if next pixel is out of mask array range
					if (start + k > mask.length - 1) {
						break;
					}
				}

				sorted = sortHorizontal(start, k, sortBy);
			}
			else
			{
				//  VERTICAL SORTING
				// ---------------------------

				// i = col, j = row

				// #col + #row * imgHeight
				start = i + j * length1;

				// skip if mask is false(black)
				if (!mask[start]) { continue; }

				// start(index) + k(progressive y-coord) * length1(width) &&
				// ( j(y-coord of start) + k(progressive y-coord) ) % height != 0
				// -> next mask pixel is true(white) && next mask pixel is not a bottom end
				while (mask[start + k * length1] && (j + k) % height != 0) {
					k++;

					// if next pixel is out of mask array range
					if (start + k * length1 > mask.length - 1) {
						break;
					}
				}

				sorted = sortVertical(start, k, sortBy);
			}

			//  INVERT
			// -----------------
			if (invert) {
				sorted = invert(sorted);
			}

			// skip already sorted pixels
			i += floor(k / width);
			j += k % width;

			//  MODIFY PIXELS[]
			// -------------------------
			k = 0;
			for (color pix : sorted) {
				if (direction == HOR) {
					pixels[start + k] = pix;
				}else{
					pixels[start + k * length1] = pix;
				}

				k++;
			}
		}
	}
}


color[] invert(color[] target){
	color[] result = new color[target.length];

	int idx = target.length - 1;
	for (color pix : target) {
		result[idx] = pix;
		idx--;
	}

	return result;
}


color[] sortHorizontal(int start, int length, int sortBy){
	color[] result = new color[length];

	arrayCopy(pixels, start, result, 0, length);

	return sortPix(sortBy, result);
}

color[] sortVertical(int start, int length, int sortBy){
	color[] result = new color[length];

	int i = 0;
	for (color pix : result) {
		result[i] = pixels[start + i * width];
		i++;
	}

	return sortPix(sortBy, result);
}


color[] sortPix(int mode, color[] target){
	int half = ceil(target.length / 2);

	color[] left = new color[half];
	color[] right = new color[target.length - half];
	arrayCopy(target, 0, left, 0, left.length);
	arrayCopy(target, half, right, 0, right.length);

	if (left.length > 1) {
		left = sortPix(mode, left);
	}

	if (right.length > 1) {
		right = sortPix(mode, right);
	}

	
	color[] result = new color[left.length + right.length];

	int leftIndex = 0, rightIndex = 0, resultIndex = 0;

    while (leftIndex < left.length && rightIndex < right.length) {
        if (sortValue(left[leftIndex], mode) <= sortValue(right[rightIndex], mode)) {
            result[resultIndex++] = left[leftIndex++];
        } else {
            result[resultIndex++] = right[rightIndex++];
        }
    }

    while (leftIndex < left.length) {
        result[resultIndex++] = left[leftIndex++];
    }

    while (rightIndex < right.length) {
        result[resultIndex++] = right[rightIndex++];
    }

	return result;
}

float sortValue(color pix, int mode){
	switch (mode) {
		case 0:
			return hue(pix);
		case 1:
			return saturation(pix);
		case 2: 
			return brightness(pix);
		default :
			println("INVALID SORT TARGET INTEGER. 0: hue, 1: saturation, 2: brightness");
			return 0.0;
	}
}