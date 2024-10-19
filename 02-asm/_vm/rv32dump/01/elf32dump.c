#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <elf.h>

void read_elf_header(FILE *file, Elf32_Ehdr elf_header) {
    // Elf32_Ehdr elf_header;

    // 讀取 ELF 檔頭
    // fread(&elf_header, 1, sizeof(Elf32_Ehdr), file);

    // 檢查 ELF 檔頭魔數 (magic number)
    if (memcmp(elf_header.e_ident, ELFMAG, SELFMAG) != 0) {
        printf("ELFMAG=%s e_ident=%s SELFMAG=%d\n", ELFMAG, elf_header.e_ident, SELFMAG);
        printf("這不是一個有效的 ELF 檔案。\n");
        // exit(1);
    }

    printf("ELF 類型: %d\n", elf_header.e_type);
    printf("機器類型: %d\n", elf_header.e_machine);
    printf("進入點位址: 0x%x\n", elf_header.e_entry);
    printf("段表偏移量: %d\n", elf_header.e_shoff);
    printf("程式表偏移量: %d\n", elf_header.e_phoff);
}

void read_section_headers(FILE *file, Elf32_Ehdr elf_header) {
    Elf32_Shdr section_header;
    char *section_names;

    // 讀取段表名稱字串表
    fseek(file, elf_header.e_shoff + elf_header.e_shstrndx * sizeof(Elf32_Shdr), SEEK_SET);
    fread(&section_header, sizeof(Elf32_Shdr), 1, file);
    section_names = malloc(section_header.sh_size);
    fseek(file, section_header.sh_offset, SEEK_SET);
    fread(section_names, section_header.sh_size, 1, file);

    // 逐一讀取並解析段表
    for (int i = 0; i < elf_header.e_shnum; i++) {
        fseek(file, elf_header.e_shoff + i * sizeof(Elf32_Shdr), SEEK_SET);
        fread(&section_header, sizeof(Elf32_Shdr), 1, file);

        printf("段名稱: %s\n", &section_names[section_header.sh_name]);
        printf("段位址: 0x%x\n", section_header.sh_addr);
        printf("段大小: %d\n", section_header.sh_size);

        if (strcmp(&section_names[section_header.sh_name], ".text")==0) {
            printf("=====> 程式段 ....\n");
            // 讀取 .text 段的內容
            char *text_section = malloc(section_header.sh_size);
            fseek(file, section_header.sh_offset, SEEK_SET);
            fread(text_section, 1, section_header.sh_size, file);

            printf(".text 段的前幾個字節:\n");
            for (int j = 0; j < section_header.sh_size && j < 64; j++) {
                printf("%02x ", (unsigned char)text_section[j]);
                if ((j + 1) % 16 == 0) printf("\n");
            }
            printf("\n");
        }
    }

    free(section_names);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("使用方式: %s <ELF 檔案>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "rb");
    if (!file) {
        perror("無法開啟檔案");
        return 1;
    }

    Elf32_Ehdr elf_header;
    fread(&elf_header, 1, sizeof(Elf32_Ehdr), file);

    read_elf_header(file, elf_header);
    read_section_headers(file, elf_header);

    fclose(file);
    return 0;
}
