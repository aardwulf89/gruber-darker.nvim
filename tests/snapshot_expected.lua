-- Highlight group names that are allowed to differ from tests/snapshot-before.txt.
return {
	-- fix 2: linked to a nonexistent key
	TelescopeNormal = true,
	-- fix 3: linked to a nonexistent key
	CmpItemAbbrDeprecated = true,
	-- fix 13: link plus italic becomes fg plus italic
	["@comment.documentation"] = true,
	-- referenced by the sidebar winhighlight but never defined
	SignColumnSB = true,
	-- capitalised; nvim_get_hl keys keep the defining case, so the old spelling shows as removed
	CmpitemKindClass = true,
	CmpItemKindClass = true,
}
