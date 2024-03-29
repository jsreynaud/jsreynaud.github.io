#!/usr/bin/python3

import sys
from launchpadlib.launchpad import Launchpad

"""
PPAOWNER = sys.argv[1]
PPA = sys.argv[2]
version = sys.argv[3]
arch = sys.argv[4]
"""
# version = "xenial"
# arch = "amd64"
# "Pending", "Published", "Superseded", "Deleted", "Obsolete"
# status = 'Superseded'
# status = "Published"
# desired_dist_and_arch = 'https://api.launchpad.net/beta/ubuntu/' + version + '/' + arch
since = '2018-09-01'
if len(sys.argv) > 1:
    since = sys.argv[1]


def produce(PPAOWNER, PPA):
    cachedir = "~/.launchpadlib/cache/"
    lp_ = Launchpad.login_anonymously('ppastats', 'production', cachedir)
    owner = lp_.people[PPAOWNER]
    for ppa in PPA:
        archive = owner.getPPAByName(name=ppa)
        for individualarchive in archive.getPublishedBinaries(created_since_date=since, ordered=False):
            # Optional filters
            # status=status
            # , distro_arch_series=desired_dist_and_arch
            # print individualarchive
            #    if individualarchive.binary_package_name == 'kicad':
            downloads = individualarchive.getDailyDownloadTotals()
            for dt in downloads:
                # print dt
                # getDailyDownloadTotals())#getDownloadCount())
                short_version = individualarchive.binary_package_version
                short_version = short_version.split("+")[0]
                short_version = short_version.split("-")[0]

                print('"' + PPAOWNER+"/"+ppa + '","' + dt + '","' + str(individualarchive.date_published) + '","' + str(individualarchive.status) + '","' + individualarchive.distro_arch_series.architecture_tag +
                      '","' + individualarchive.distro_arch_series.distroseries.name + '","' + individualarchive.binary_package_name + '","' + individualarchive.binary_package_version + '",' + str(downloads[dt]) + ',"'+short_version+'"')
#    print individualarchive.getDailyDownloadTotals()


#PPAOWNER = "js-reynaud"
#PPA = ["kicad-5", "ppa-kicad", "kicad-dev-nightly", "kicad-4", "kicad-5.1"]
print("PPA,Date,Date published,Status,Arch,Ubuntu version,Package name,Package version,Download count,Short version")
produce("js-reynaud", ["kicad-5", "ppa-kicad", "kicad-dev-nightly", "kicad-4"])
produce("kicad", ["kicad-dev-nightly", "kicad-5.1-releases", "kicad-6.0-releases", "kicad-7.0-releases", "kicad-7.0-nightly"])
