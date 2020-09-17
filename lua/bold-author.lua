function Block(el)
  if el.t == "Para" or el.t == "Plain" then
    for i, j in ipairs(el.content) do

      if el.content[i].t == "Str"
      and el.content[i].text == "Barbone,"
      and el.content[i+1].t == "Space"
      and el.content[i+2].t == "Str"
      and el.content[i+2].text:find("^J.") then -- assuming no other Barbone, J.
        local j, k = el.content[i+2].text:find("^J.")
        local rest = el.content[i+2].text:sub(k+1)  -- empty if e+1>length
        el.content[i] = pandoc.Strong { pandoc.Str("Barbone, ") }
        el.content[i+1] = pandoc.Strong{ pandoc.Str("J. ") }
        el.content[i+2] = pandoc.Strong{ pandoc.Str("") }
        el.content[i+3] = pandoc.Strong{ pandoc.Str("M.") }
        if el.content[i+4].text:find(",") then
          el.content[i+4] = pandoc.Str(", ")
        else
          el.content[i+4] = pandoc.Str("")
        end
      end
    end
  end
  return el
end
