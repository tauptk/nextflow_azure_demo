using System.Collections.Generic;
using CommandLine;


class CreateCompositionOptions {
  [Option(Required=true, HelpText="Composition output file path")]
  public string Output { get; set; }

  [Option('i', Required=true, Separator=',', HelpText="A list of input files for composition")]
  public IList<string> InputFiles { get; set; }

  [Option('c', Default=3, HelpText="A number of files to keep in single row")]
  public int FilesPerRowCount { get; set; }
}