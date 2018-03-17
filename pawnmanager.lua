local pawnmanager = {}

-- dumb placeholders
function pawnmanager.create_pawn(o)
	local pid = idcounter.get_id('pawn')

	o.id = pid
	o.status = {}
	o.on_map = false

	if not o.faith then
		pawnmanager._roll_faith(o)
	end
	if not o.job then
		pawnmanager._roll_job(o)
	end
	if not o.gender then
		pawnmanager._roll_gender(o)
	end
	if not o.name then
		pawnmanager._roll_name(o)
	end

	if not o.faction then
		-- what makes a man turn neutral?
		o.faction = "neutral"
	end
	if not o.sprite then
		if o.gender == "female" then
			o.sprite = "abby"
		else
			o.sprite = "quentin"
		end
	end
	if not o.movespeed then
		o.movespeed = 6
	end
	if not o.gender then
		o.movetype = "walk"
	end

	pawns[pid] = pawn:new(o)
	return pid
end

function pawnmanager._roll_faith(o)
	o.faith = mymath.choose_random_weighed({
		calyptra = 10,
		ecstatic = 10,
		empyreal = 10,
		ophidian = 10,
		faithless = 10,
	})
end

function pawnmanager._roll_job(o)
	if o.faith == "calyptra" then
		o.job = mymath.choose_random_weighed({
			priest = 10,
			assassin = 10,
		})
	elseif o.faith == "ecstatic" then
		o.job = mymath.choose_random_weighed({
			shaman = 10,
			bard = 10,
		})
	elseif o.faith == "empyreal" then
		o.job = mymath.choose_random_weighed({
			sorcerer = 10,
			monk = 10,
		})
	elseif o.faith == "ophidian" then
		o.job = mymath.choose_random_weighed({
			oracle = 10,
			knight = 10,
		})
	elseif o.faith == "faithless" then
		o.job = mymath.choose_random_weighed({
			ranger = 10,
			rogue = 10,
		})
	else
		o.job = "bugmaster"
	end
end

function pawnmanager._roll_gender(o)
	o.gender = mymath.choose_random_weighed({
		male = 10,
		female = 10,
	})
end

function pawnmanager._roll_name(o)
	if o.gender == "female" then
		o.name = mymath.choose_random_weighed({
			abby = 10,
			beth = 10,
		})
	elseif o.gender == "male" then
		o.name = mymath.choose_random_weighed({
			quentin = 10,
			roger = 10,
		})
	else
		o.name = "izzy"
	end
end

return pawnmanager
