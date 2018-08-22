## README for `image_format_converter`

This is a Ruby script for converting images of a specified format in a specified location into another specified format, in a secondary specified location.  Additional options for modifying the converted images and returning an HTML manifest are available.
See [an example CSV manifest here](sample_manifest.csv), developed primarily for Mac users, but it can be run on any machine meeting the requirements below. 

## Requirements

* Ruby 2.3.0 or higher
* A CSV manifest containing information described below:
    
    ### Required columns
    
    * `original_location` - The [absolute file path](https://www.computerhope.com/jargon/a/absopath.htm) to the directory containing the source images to be converted.
    * `converted_location` - The [absolute file path](https://www.computerhope.com/jargon/a/absopath.htm) to the directory where the script should save the converted images.
    * `original_format` - The file extension of the original format of the images.  This should be in all-lowercase with no leading period.
    * `converted_format` - The file extension of the desired converted format of the images.  This should be in all-lowercase with no leading period.
    
    ### Optional columns
    
    * `ppi` - The [pixels-per-inch](https://en.wikipedia.org/wiki/Pixel_density) numeric value desired for each converted image.  If unsure what should be here, leave as ```72``` and the script should run without a problem.
    * `html_manifest_name` - the filename for an HTML manifest alphabetically listing and displaying all converted images in the converted location	
    * `rename_delimiter` - If supplied, converted files will be renamed, appending the specified delimiter and the file's checksum.  This is advisable in case of filename collision at the source.
    * `scale_dimensions` - 	If supplied, converted files will be scaled to the specified proportions.  Example value: `800x600`.
    * `skip_conversion` - If set to `TRUE`, the script will skip image conversion for that entry in the manifest.  This is useful if you just want to get an HTML manifest of files in the converted location.
   
    
## Usage

To run image conversion(s) described in the CSV manifest,, open a [terminal window](http://blog.teamtreehouse.com/introduction-to-the-mac-os-x-command-line), type in the following, then press Enter:

```bash
./convert_images.sh $CSV_MANIFEST
```

Where `$CSV_MANIFEST` is the path to the CSV manifest file described above.  Your converted images should be available at their converted location.

## Usage explained

Alternative to using the bash script, you can execute this workflow manually.  Below is a more detailed explanation.

This workflow requires the use of two scripts.  The first one creates a set of machine-readable files known as [todo files](https://github.com/upenn-libraries/todo_runner) that the second script uses to run conversion tasks. 

To create the todo files, execute the following command from the terminal:

```bash
ruby image_format_converter_make_todos.rb $CSV_MANIFEST $TODOS_DESTINATION
```

Where `$CSV_MANIFEST` is the path to the CSV manifest file described above, and `$TODOS_DESTINATION` is the path on the filesystem where the script should write the todo files.

To then run conversion tasks, execute the following command from the terminal:

```bash
ruby image_format_converter_convert.rb $TODOS_DESTINATION/*.todo
```

Where `$TODOS_DESTINATION` matches the `$TODOS_DESTINATION` argument given in the first step.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/upenn-libraries/image_format_converter](https://github.com/upenn-libraries/image_format_converter).

## License

This code is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0).
