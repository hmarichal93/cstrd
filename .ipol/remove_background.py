import argparse
from pathlib import Path

import numpy as np
from urudendro.remove_salient_object import remove_salient_object
from urudendro.image import load_image, write_image


def posprocess(output_path):
    """
    Postprocess the output image to ensure it is in the correct format.
    This function can be extended to include additional postprocessing steps if needed.
    """
    img = load_image(output_path)
    square_width_px = 50
    img[:, 0:square_width_px] = [255, 255, 255]  # White square in the top-left corner
    img[:, -square_width_px:] = [255, 255, 255]  # White square in the top-right corner
    img[0:square_width_px, :] = [255, 255, 255]  # White square in the top-left corner
    img[-square_width_px:, :] = [255, 255, 255]  # White square in the bottom-left corner
    write_image(output_path, img)  # Save the modified image back to the output path

if __name__ == "__main__":


    parser = argparse.ArgumentParser(description="Remove background from image")
    parser.add_argument("--input", type=str, required=True, help="Input image path")
    parser.add_argument("--output", type=str, required=True, help="output image path")
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)



    try:
        if not input_path.exists():
            raise FileNotFoundError(f"Input image {input_path} not found")

        remove_salient_object(str(input_path), str(output_path))
        posprocess(str(output_path))
    except Exception as e:
        #write to file
        with open("demo_failure.txt", "w") as f:
            f.write(str(e))
