#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <elf.h>
#include <stdbool.h>

#include "riscv.c"
#include "lib.c"
#include "dasm.c"

bool is_dump = true;

void dump_elf_header(FILE *file, Elf32_Ehdr elf_header) {
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

void dump_section_headers(FILE *file, Elf32_Ehdr elf_header) {
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

        printf("段名稱: %-20s ", &section_names[section_header.sh_name]);
        printf("段位址: 0x%08x ", section_header.sh_addr);
        printf("段大小: %8d\n", section_header.sh_size);
        if (is_dump) {
            char *section_body = malloc(section_header.sh_size);
            fseek(file, section_header.sh_offset, SEEK_SET);
            fread(section_body, 1, section_header.sh_size, file);

            if (strcmp(&section_names[section_header.sh_name], ".text")==0) {
                printf(".text 段反組譯結果:\n");
                for (int j = 0; j < section_header.sh_size; j+=4) { //  && j < 128
                    uint32_t instruction = decode_little_endian32(&section_body[j]);
                    char type = get_riscv_instr_type(instruction);
                    char asm1[100];
                    disassemble(instruction, asm1);
                    printf("%08x %c %s\n", instruction, type, asm1);
                }
                printf("\n");
            } else if (strcmp(&section_names[section_header.sh_name], ".symtab") == 0) {
                // 如果是符號表，則讀取並顯示符號
                printf("=====> 符號表 ....\n");

                Elf32_Shdr strtab_header;
                // 找到符號表的字串表
                fseek(file, elf_header.e_shoff + section_header.sh_link * sizeof(Elf32_Shdr), SEEK_SET);
                fread(&strtab_header, sizeof(Elf32_Shdr), 1, file);

                // 讀取符號表
                Elf32_Sym *symbols = malloc(section_header.sh_size);
                fseek(file, section_header.sh_offset, SEEK_SET);
                fread(symbols, section_header.sh_size, 1, file);
                
                // 讀取字串表
                char *strtab = malloc(strtab_header.sh_size);
                fseek(file, strtab_header.sh_offset, SEEK_SET);
                fread(strtab, strtab_header.sh_size, 1, file);

                int num_symbols = section_header.sh_size / sizeof(Elf32_Sym);
                for (int j = 0; j < num_symbols; j++) {
                    printf("符號: %s, 位址: 0x%08x\n",
                        &strtab[symbols[j].st_name], symbols[j].st_value);
                    if (strcmp(&strtab[symbols[j].st_name], "main")==0)
                        printf("==> main 的位址在 0x%08x\n", symbols[j].st_value);
                }

                free(symbols);
                free(strtab);
            } else if (strcmp(&section_names[section_header.sh_name], ".strtab") == 0) {
                printf("字串表:\n");
                for (int j = 0; j < section_header.sh_size; j++) {
                    char ch = section_body[j];
                    printf("%c", ch=='\0'?'/':ch);
                }
            } else {
                printf("整段內容印出:\n");
                for (int j = 0; j < section_header.sh_size; j++) { //  && j < 128
                    printf("%02x ", (unsigned char)section_body[j]);
                    if ((j + 1) % 16 == 0) printf("\n");
                }
            }
            printf("\n\n");
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

    dump_elf_header(file, elf_header);
    dump_section_headers(file, elf_header);
    // load_to_memory(file, elf_header);

    fclose(file);
    return 0;
}
