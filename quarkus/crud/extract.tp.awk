#!/usr/bin/awk -f

BEGIN	{
       	numFiles=0;
	minTime=10000;
	maxTime=0;
	}

BEGINFILE {
	  file = substr(FILENAME, index(FILENAME, "tp.")+3);
	  files[numFiles++] = file;
	  }

/At/	{
	time = $2;
	value = $4;
       	tp[file, time] = value;
	if (time < minTime) minTime = time;
	if (time > maxTime) maxTime = time;
	seen[time] = 1;
       	}

END	{
	printf("Time");
	for (f=0;f < numFiles;f++)
		printf ", %s", files[f];
	print "";

	for (t=minTime; t <= maxTime; t++)
       		{
		if (seen[t])
	       		{
			printf("%s", t);
			for (f=0;f < numFiles;f++)
				printf(", %f", tp[files[f], t]);
			print "";
			}
		}
	}
