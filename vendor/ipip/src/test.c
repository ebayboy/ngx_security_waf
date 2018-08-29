#include <stdio.h>
#include <string.h>
#include "ipip.h"

char *strtok_r_2(char *str, char const *delims, char **context) {
    char *p, *ret = NULL;

    if (str != NULL)
        *context = str;

    if (*context == NULL)
        return NULL;

    if ((p = strpbrk(*context, delims)) != NULL) {
        *p = 0;
        ret = *context;
        *context = ++p;
    }
    else if (**context) {
        ret = *context;
        *context = NULL;
    }
    return ret;
}

/* db format :
 * [
 * "GOOGLE.COM", // country_name
 * "GOOGLE.COM", // region_name
 * "",             // city_name
 * "google.com", // owner_domain
 * "level3.com", // isp_domain
 * "", // latitude
 * "", // longitude
 * "", // timezone
 * "", // utc_offset
 * "", // china_admin_code
 * "", // idd_code
 * "", // country_code
 * "", // continent_code
 * "IDC", // idc
 * "", // base_station
 * "", // country_code3
 * "", // european_union
 * "", // currency_code
 * "", // currency_name
 * "ANYCAST" // anycast
 * ]
 **/

int main(int argc, char **argv) {

    char *path = "../../../conf/ipip_station.datx";
    char *ip;
    char result[128] = {0};
    int i = 0;
    char *title[] = {
        "country_name",
        "region_name",
        "city_name",
        "owner_domain",
        "isp_domain",
        "latitude",
        "longitude",
        "timezone",
        "utc_offset",
        "china_admin_code",
        "idd_code",
        "country_code",
        "continent_code",
        "idc",
        "base_station",
        "country_code3",
        "european_union",
        "currency_code",
        "currency_name",
        "anycast",
    };

    init(path);
    if (argc > 1) {
        ip = argv[1];     
    } else {
        ip = "123.121.117.72";
    }

    find(ip, result);

    printf("%s -> %s\n", ip, result);
    char *rst = NULL;
    char *lasts;
    rst = strtok_r_2(result, "\t", &lasts);

    for (i = 0;rst && i < 20;i++) {
        printf("[%d][%s]:[%s]\n", i, title[i], rst);
        rst = strtok_r_2(NULL, "\t", &lasts);
    }

    destroy();

    return 0;
}
