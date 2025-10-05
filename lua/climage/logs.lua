-- Create RingBuffer

local RingBuffer = {}
RingBuffer.__index = RingBuffer

function RingBuffer.new(size)
    return setmetatable({
        size = size,
        buffer = {},
        head = 1,
        count = 0,
    }, RingBuffer)
end

function RingBuffer:push(item)
    local entry = {
        ts = os.date("%Y-%m-%d %H:%M:%S"),
        msg = item,
    }
    self.buffer[self.head] = entry
    self.head = (self.head % self.size) + 1
    if self.count < self.size then
        self.count = self.count + 1
    end
end

function RingBuffer:items()
    local items = {}
    local idx = (self.head - self.count - 1) % self.size + 1
    for i = 1, self.count do
        local entry = self.buffer[idx]
        items[#items + 1] = string.format("[%s] %s", entry.ts, entry.msg)
        idx = (idx % self.size) + 1
    end
    return items
end

return RingBuffer
