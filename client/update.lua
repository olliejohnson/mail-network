urls = {
    {"client.lua", "https://raw.githubusercontent.com/olliejohnson/mail-network/main/client/client.lua"},
    {"cryptoNet.lua", "https://raw.githubusercontent.com/olliejohnson/mail-network/main/client/cryptoNet.lua"}
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

for key, value in ipairs(urls) do
    download(unpack(value))
end