data:extend({{
    type = "int-setting",
    name = "tb_thought-duration",
    setting_type = "runtime-global",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 30,
    order = "a1"
}, {
    type = "int-setting",
    name = "tb_time-between-thoughts",
    setting_type = "runtime-global",
    default_value = 30,
    minimum_value = 10,
    maximum_value = 600,
    order = "a2"
}, {
    type = "bool-setting",
    name = "tb_show-bubbles",
    setting_type = "runtime-global",
    default_value = true,
    order = "b1"
}, {
    type = "bool-setting",
    name = "tb_show-thoughts_joking",
    setting_type = "runtime-global",
    default_value = true,
    order = "c1"
}, {
    type = "bool-setting",
    name = "tb_show-thoughts_sentient",
    setting_type = "runtime-global",
    default_value = true,
    order = "c2"
}, {
    type = "bool-setting",
    name = "tb_show-thoughts_depressed",
    setting_type = "runtime-global",
    default_value = false,
    order = "c3"
}, {
    type = "bool-setting",
    name = "tb_show-thoughts_factorio",
    setting_type = "runtime-global",
    default_value = true,
    order = "c4"
}})

if mods["expansion-reminder"] then
    data:extend({{
        type = "bool-setting",
        name = "tb_show-thoughts_fff",
        setting_type = "runtime-global",
        default_value = true,
        order = "c5"
    }})
end
