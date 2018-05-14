local T, C, L = Tukui:unpack()


local dimFactor = .8

for name,col in pairs(T.Colors.class) do
    local r,g,b = unpack(col)
    T.Colors.class[name] = {r*dim, g*dim, b*dim}
end