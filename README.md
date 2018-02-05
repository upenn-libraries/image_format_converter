## README for image_format_converter

This is a minimal Ruby script for converting images of a specified format in a specified location into another specified format, in a secondary specified location.  This was developed as a proof-of-concept script to help in TIF-to-JP2 conversion for the Hathi Scanned Books project.


### Configuring

To use this script, create a manifest YML file modeled on the contents of ```config.yml.example```.

Populate ```config.yml``` as follows:
```yml
original_location: /absolute/path/to/originals
converted_location: /absolute/path/to/converted
original_format: tif
converted_format: jp2
ppi: 72
```

Required arguments are as follows:
* ```original_location``` - The [absolute file path](https://www.computerhope.com/jargon/a/absopath.htm) to the directory containing the source images to be converted.
* ```converted_location``` - The [absolute file path](https://www.computerhope.com/jargon/a/absopath.htm) to the directory where the script should save the converted images.
* ```original_format``` - The file extension of the original format of the images.  This should be all-lowerase, with no leading period, as shown in the example YAML file.
* ```converted_format``` - The file extension of the desired converted format of the images.  This should be all-lowerase, with no leading period, as shown in the example YAML file.

Optional arguments are as follows:
* ```ppi``` - The [pixels-per-inch](https://en.wikipedia.org/wiki/Pixel_density) numeric value desired for each converted image.  If unsure what should be here, leave as ```72``` and the script should run without a problem.


### Executing

To execute the script, run the following command in the terminal from within the script's project directory:
```bash
ruby converter.rb $MANIFEST_YML
```
Where ```$MANIFEST_YML``` is the [absolute file path](https://www.computerhope.com/jargon/a/absopath.htm) to the manifest YML file for the conversion batch.

#### Flags

Optional flags are as follows:

* `-rDELIMITER, --rename DELIMITER` : Rename converted files, appending `DELIMITER` and the file's checksum.  This is advisable in case of filename collision at the source.
* `-s --small` : Make converted files small/for quick check only.
* `-mMANIFEST_NAME --manifest MANIFEST_NAME` : Return an HTML manifest of `MANIFEST_NAME` listing all converted images in the converted location.
* `-k --skip-conversion` : Skip image conversion, useful if you just want to get an HTML manifest of files in the converted location.

See the example bash scripts in the `scripts/` directory for examples leveraging bash on multiple YML files.
