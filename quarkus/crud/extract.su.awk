#!/usr/bin/awk -f

BEGIN	{
       	numFiles=0;
	}

BEGINFILE {
	  file = substr(FILENAME, index(FILENAME, "out.")+4);
	  files[numFiles++] = file;
	  line = 0;
	  }

/JITServer/ { next; }

//	{
	if (line == 0)
		{
		startTime = convertTime($1)
		line = 1;
		}
	else if (line == 1)
		{
		insideContainerTime = convertTime($1)
		containerStart[file] = (insideContainerTime - startTime);
		line = 2;
		}
	else if (line == 2)
		{
		serverStartedTime = convertTime($1)
		serverStartTime[file] = (serverStartedTime - insideContainerTime);
		line = 3;
		}
	}

END	{
	print "Scenario, containerStart, serverStart";
	for (f=0;f < numFiles;f++)
		{
		file = files[f];
		print file ", " containerStart[file] ", " serverStartTime[file];
		}
	}

function convertTime(timeString) {
	n = split(timeString, parts, "[:]");
	if (n == 4) return parts[3] * 1000 + parts[4];
	if (n == 3) return parts[3] * 1000;
	return 0;
}
