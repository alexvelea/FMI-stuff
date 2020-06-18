#include <dirent.h>
#include <string.h>

#include "utils.h"

#ifdef VERBOSE3
#define VERBOSE2
#endif

#ifdef VERBOSE2
#define VERBOSE1
#endif

int find_all_out(char *path)
{
	DIR *dir_stream;
	struct dirent *dirp;
	
    if ((dir_stream = opendir(path)) == NULL) {
        msg("Failed to open directory: %s", path);
		return 0;
	}

	while ((dirp = readdir(dir_stream)) != NULL) {
        // omit . and ..
		if (strcmp(dirp->d_name, ".") == 0)
			continue;
		if (strcmp(dirp->d_name, "..") == 0)
			continue;

		int child_path_len = strlen(path) + 1 + strlen(dirp->d_name);
		// allocate space for child path
        char* child_path = (char*) xmalloc(sizeof(char) * (child_path_len + 1));
		
        // create child path
        strcpy(child_path, path);
		strcat(child_path, "/");
		strcat(child_path, dirp->d_name);

		if (dirp->d_type == DT_REG) {
			if (child_path_len >= 4 && strcmp(child_path + child_path_len - 4, ".out") == 0) {
				if (unlink(child_path) < 0) {
                    msg("[Failed to delete] %s", child_path);
				} else {
#ifdef VERBOSE1
                    msg("[Delete] %s", child_path);
#endif
                }
			} else {
#ifdef VERBOSE2
                msg("[Skip] %s", child_path);
#endif
            }
		} else if (dirp->d_type == DT_DIR) {
#ifdef VERBOSE3
            msg("[enter] %s", child_path);
#endif
			if (!find_all_out(child_path)) {
				free(child_path);
				closedir(dir_stream);
				return 1;
			}
#ifdef VERBOSE3
            msg("[exit] %s", child_path);
#endif
		}

		free(child_path);
	}
	closedir(dir_stream);
	return 1;
}

int main(int argc, char** argv)
{
    if (argc < 2)
        die("Provide a directory");

    if (!dir_exists(argv[1]))
        die("%s is not a directory", argv[1]);

    int len = strlen(argv[1]);

    while (len > 1 && argv[1][len - 1] == '/') {
        argv[1][len - 1] = '\0';
        len -= 1;
    }

    find_all_out(argv[1]);

    return 0;
}
