#!/usr/bin/awk -f

BEGIN	{
       	numFiles=0;
	}

BEGINFILE {
	  file = substr(FILENAME, index(FILENAME, "fp.")+3);
	  files[numFiles++] = file;
	  }

//	{
	value = $1;
	fp[file] = value;
       	}

END	{
	print "Scenario, Footprint";
	for (f=0;f < numFiles;f++)
		print files[f] ", " fp[files[f]];
	}
