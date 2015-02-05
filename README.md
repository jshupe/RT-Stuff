# RT-Stuff
Random scripts to interact with RequestTracker

These two scripts are used with an "auto" queue, which
is where I have servers send all of their daily outputs,
backup notifications, etc.

RT_clear_auto.pl:	Delete all tickets > 72H old

RT_missing_auto.pl:	Notify if tickets were not
			received with specific subject
			lines, specified one per line
			in RT_missing_auto.cfg
