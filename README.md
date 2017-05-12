## README for image_format_converter

This is a minimal Ruby script for converting images of a specified format in a specified location into another specified format, in a secondary specified location.  This was developed as a proof-of-concept script to help in TIF-to-JP2 conversion for the Hathi Scanned Books project.


### Configuring

To use this script, copy the contents of ```config.yml.example``` into a file called ```config.yml``` in the same directory as the ```converter.rb``` file.

Populate ```config.yml``` as follows:
```yml
original_location: /absolute/path/to/originals
converted_location: /absolute/path/to/converted
original_format: tif
converted_format: jp2
ppi: 72
```

Each argument should be populated with the following values:
* ```original_location``` - The [absolute file path](https://www.computerhope.com/jargon/a/absopath.htm) to the directory containing the source images to be converted.
* ```converted_location``` - The [absolute file path](https://www.computerhope.com/jargon/a/absopath.htm) to the directory where the script should save the converted images.
* ```original_format``` - The file extension of the original format of the images.  This should be all-lowerase, with no leading period, as shown in the example YAML file.
* ```converted_format``` - The file extension of the desired converted format of the images.  This should be all-lowerase, with no leading period, as shown in the example YAML file.
* ```ppi``` - The [pixels-per-inch](https://en.wikipedia.org/wiki/Pixel_density) numeric value desired for each converted image.  If unsure what should be here, leave as ```72``` and the script should run without a problem.


### Executing

To execute the script, run the following command in the terminal from within the script's project directory:
```bash
ruby converter.rb
```
