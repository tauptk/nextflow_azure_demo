using System;
using System.Linq;
using System.Drawing;
using CommandLine;

namespace composition_app
{
    class Program
    {
        static void Main(string[] args)
        {
            var result = Parser.Default.ParseArguments<CreateCompositionOptions>(args)
                .WithParsed(options => {
                    var files = options.InputFiles;
                    var rowLength = options.FilesPerRowCount;
                    if(files.Count % rowLength != 0){
                        throw new ArgumentException(
                            "Invalid number of files entered. " + 
                            $"{files.Count} files provided, " + 
                            $"but it cannot fill composition with {rowLength} columns!"
                        );
                    }
                    var bitmaps = files.Select(x => new Bitmap(Image.FromFile(x)));
                    var smallestWidth = bitmaps.Min(x => x.Width);
                    var smallestHeight = bitmaps.Min(x => x.Height);
                    var rowsOfBitmaps = Enumerable.Range(0, files.Count / rowLength)
                                        .Select(x => bitmaps.Skip(x * rowLength).Take(rowLength).ToList())
                                        .ToList();
                    var compositionBitmap = new Bitmap(smallestWidth * rowLength, smallestHeight * rowsOfBitmaps.Count);
                    var compositionGraphics = Graphics.FromImage(compositionBitmap);
                    for(int row = 0; row < rowsOfBitmaps.Count; row++){
                        for(int column = 0; column < rowLength; column++){
                            var element = rowsOfBitmaps[row][column];
                            var scale = Math.Min((float)smallestWidth / (float)element.Width, (float)smallestHeight / (float)element.Height);
                            var width = element.Width * scale;
                            var height = element.Height * scale;
                            compositionGraphics.DrawImage(
                                element, 
                                x: smallestWidth * column, 
                                y: smallestHeight * row, 
                                width: width,
                                height: height
                            );
                        }
                    }
                    compositionBitmap.Save(options.Output);
                });
        }
    }
}
