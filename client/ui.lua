local basalt = require("basalt")

local main = basalt.createFrame()

local messages_list = main:addFrame():setScrollable():setSize("parent.w/2", "parent.h"):setPosition(0, 0)
local list = messages_list:addList()

messages = {{id = 0,subject = "Important", sender = "jacoberrol", body = "hello", has_item = true, item_id = "fwofmwlk"}}
frames = {}

function getMessageFromSubject(subject)
    for message in pairs(messages) do
        if message.subject == subject then
            return message
        end
    end
end

function onMessageSelect(self, event, item)
    message = getMessageFromSubject(item.text)
    messages_list:hide()
    frames[message.id]:show()

end

function parse_message(message, list)
    list:addItem(message.subject)
    message = main:addFrame():setPosition(0, 0):setSize("{parent.w/2}", "{parent.h}"):hide()
    message:addLabel():setText(message.body):setFontSize(2)
    frames[message.id] = message
end

basalt.autoUpdate()