--[[
	Generates a scatter plot visualizing the commit activity per daytime.
--]]


-- Script meta-data
meta.title = "Commit Scatter"
meta.descritpion = "Scatter plot of commit activity"
meta.options = {{"-bARG, --branch=ARG", "Select branch"},
                {"-tARG, --type=ARG", "Select image type"}}

-- Revision callback function
function callback(r)
	if r:date() == 0 then
		return
	end

	local date = os.date("*t", r:date())
	table.insert(dates, r:date())
	table.insert(daytimes, date["hour"] + date["min"] / 60)
end

-- Main report function
function main()
	dates = {}     -- Commit timestamps
	daytimes = {}  -- Time in hours and hour fractions

	-- Gather data
	local branch = pepper.report.getopt("b,branch", pepper.report.repository():main_branch())
	pepper.report.walk_branch(callback, branch)

	-- Generate graph
	local imgtype = pepper.report.getopt("t, type", "svg")
	local p = pepper.gnuplot:new()
	p:set_title("Commit Activity (on " .. branch .. ")")
	p:set_output("activity." .. imgtype, 600, 200)
	p:cmd([[
set xdata time
set timefmt "%s"
set format x "%b %y"
set decimal locale
set format y "%'.0f"
set yrange [0:24]
set ytics 6
set xtics nomirror
set xtics rotate by -45
set rmargin 8
set grid
set pointsize 0.1]])
	p:plot_series(dates, daytimes, {}, "dots")
end