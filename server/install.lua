urls = {
    {"server.lua", "https://raw.githubusercontent.com/olliejohnson/mail-network/main/server/server.lua"},
    {"cryptoNet.lua", "https://raw.githubusercontent.com/olliejohnson/mail-network/main/server/cryptoNet.lua"}
}

files = {
    "card.tbl"
}

function download(name, url)
    request = http.get(url)
    data = request.readAll()

    if fs.exists(name) then
        fs.delete(name)
        file = fs.open(name, "w")
        file.write(data)
        file.close()
    else
        file = fs.open(name, "w")
        file.write(data)
        file.close()
    end
end

function file_create(name)
    if fs.exists(name) then
        return
    else
        file = fs.open(name, "w")
        file.write("")
        file.close()
    end
end

for k, v in ipairs(urls) do
    download(unpack(v))
end

for k, v in ipairs(files) do
    file_create(v)
end