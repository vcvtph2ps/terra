struct String {
    char value[];
};

fn nametable_format(auto e) {
    if(!e.used) return "";
    u64 address = addressof(nametable) + e.nametable_offset;
    String string @ address;
    return string.value;
};

struct Table {
    u16 entry_size;
    u64 entry_count;
    u64 offset;
};

struct File {
    u64 nametable_offset;
    u64 data_offset;
    u64 size;
    u64 next_index;
    u64 parent_index;
    bool used;
    bool is_symlink;
    u8 data[size] @ data_offset;
} [[format("nametable_format")]];

struct Dir {
    u64 nametable_offset;
    u64 filetable_index;
    u64 dirtable_index;
    u64 next_index;
    u64 parent_index;
    bool used;
} [[format("nametable_format")]];

u8 signature[4] @ 0x0;
u16 revision @0x4;
u16 header_size @ 0x6;
u64 root_index @ 0x08;
u64 nametable_offset @ 0x10;
u64 nametable_size @ 0x18;
Table dirtable_desc @ 0x20;
Table filetable_desc @ 0x32;

char nametable[nametable_size] @ nametable_offset;
Dir dirtable[dirtable_desc.entry_count] @ dirtable_desc.offset;
File filetable[filetable_desc.entry_count] @ filetable_desc.offset;
