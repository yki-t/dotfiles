tell application "System Events"
	-- get PID of the current active Alacritty window
	set activeAlacrittyPID to get unix id of first application process whose name is "Alacritty" and frontmost = true
	-- get PID of the current active shell
	set shellPID to do shell script "pgrep -P " & activeAlacrittyPID & " -a zsh"
	-- get the current working directory
	set shellCWD to do shell script "lsof -a -d cwd -p " & shellPID & " -F n | cut -c 2- | tail -n1"
	-- run a new Alacritty instance within the current working directory
	do shell script "open -nb io.alacritty --args --working-directory " & shellCWD
end tell
