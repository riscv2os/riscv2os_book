#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <elf.h>
#include <stdbool.h>

#include "riscv.c"
#include "lib.c"
#include "dasm.c"

typedef struct block_t {
    char *body;
    int entry;
    int size;
} block_t;

void load_into_memory(FILE *file, Elf32_Ehdr elf_header, block_t *code_block) {
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
        char *section_name = &section_names[section_header.sh_name];
        if (strcmp(&section_names[section_header.sh_name], ".text")==0) {
            code_block->size = section_header.sh_size;
            code_block->body = malloc(section_header.sh_size);
            fseek(file, section_header.sh_offset, SEEK_SET);
            fread(code_block->body, 1, section_header.sh_size, file);
        } else if (strcmp(&section_names[section_header.sh_name], ".symtab") == 0) {
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
                if (strcmp(&strtab[symbols[j].st_name], "main")==0) {
                    // printf("==> main 的位址在 0x%08x\n", symbols[j].st_value);
                    code_block->entry = symbols[j].st_value;
                }
            }

            free(symbols);
            free(strtab);
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

    // dump_elf_header(file, elf_header);
    // dump_section_headers(file, elf_header);
    block_t code_block;
    load_into_memory(file, elf_header, &code_block);
    disassemble_block(code_block.body, code_block.size);
    printf("entry=%04x\n", code_block.entry);
    fclose(file);
    return 0;
}
