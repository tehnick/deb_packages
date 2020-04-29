#!/bin/bash
#
# Library of common functions


GetOldVersion()
{
    if [ -z "${EPOCH}" ]; then
        export OLD_VER_FULL=$(head -n 1 "${PKG_DIR}/${PACKAGE}-debian/debian/changelog" | sed -e "s/.* (\(.*\)) .*/\1/")
    else
        export OLD_VER_FULL=$(head -n 1 "${PKG_DIR}/${PACKAGE}-debian/debian/changelog" | sed -e "s/.* (${EPOCH}\(.*\)) .*/\1/")
    fi
    if [ -z "$(echo ${OLD_VER_FULL} | grep '~exp')" ]; then
        export OLD_VER=$(echo ${OLD_VER_FULL} | sed -e "s/^\(.*\)-[0-9].*$/\1/")
        export OLD_SFX=$(echo ${OLD_VER_FULL} | sed -e "s/^.*\(-[0-9].*\)$/\1/")
    else
        export OLD_VER=$(echo ${OLD_VER_FULL} | sed -e "s/^\(.*\)-[0-9]*\~exp.*$/\1/")
        export OLD_SFX=$(echo ${OLD_VER_FULL} | sed -e "s/^.*\(-[0-9]*\~exp.*\)$/\1/")
    fi
    if [ -z "$(echo ${OLD_VER_FULL} | grep 'ppa')" ]; then
        export OLD_VER=$(echo ${OLD_VER_FULL} | sed -e "s/^\(.*\)-[0-9]*$/\1/")
        export OLD_SFX=$(echo ${OLD_VER_FULL} | sed -e "s/^.*\(-[0-9]*\)$/\1/")
    else
        export OLD_VER=$(echo ${OLD_VER_FULL} | sed -e "s/^\(.*\)-[0-9]*ppa.*$/\1/")
        export OLD_SFX=$(echo ${OLD_VER_FULL} | sed -e "s/^.*\(-[0-9]*ppa[0-9]*\).*$/\1/")
    fi
}

GetNewVersion()
{
    if [ ! -z "${NEW_VER}" ] && [ "${1}" != "print-versions" ]; then
        return 1
    fi
    return 0
}

DisplayVersions()
{
    echo ;
    echo "${1}"
    echo ;
    echo "On $(echo \"${1}\" | cut -f 3 -d /) now available such versions:"
    echo "${VER_LIST}" | sort -r -V | head -n10
    echo ;

    echo "OLD_VER = ${OLD_VER}"
    echo "NEW_VER = ${NEW_VER}"
    echo "OLD_VER_FULL = ${EPOCH}${OLD_VER_FULL}"
    echo "NEW_VER_FULL = ${EPOCH}${NEW_VER_FULL}"
    echo ;
}


# Display versions for unstable packages
DisplayVersionsUnstable()
{
    echo "Old  commit: ${OLD_COMMIT}"
    echo "Last commit: ${LAST_COMMIT}"
    echo "OLD_VER_FULL = ${EPOCH}${OLD_VER_FULL}"
    echo "NEW_VER_FULL = ${EPOCH}${NEW_VER_FULL}"
}


# Show versions for summarized table (on special HTML page)
PrintVersions()
{
    if [ "${1}" = "print-versions" ]; then
        if [ -z "${2}" ]; then
            echo "File name must be not empty!"
            exit 1
        else
            HTML_FILE="${2}"
            echo "<td style=\"font-weight: bold;\">" >> "${HTML_FILE}"
            echo "${PACKAGE}" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            echo "<td>" >> "${HTML_FILE}"
            echo "${EPOCH}${OLD_VER_FULL}" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            if [ "${NEW_VER}" != "${OLD_VER}" ]; then
                if ( dpkg --compare-versions "${NEW_VER}" gt "${OLD_VER}" ); then
                    echo "<td class=\"color-outdated\">" >> "${HTML_FILE}"
                else
                    echo "<td class=\"color-newer\">" >> "${HTML_FILE}"
                fi
            else
                echo "<td class=\"color-actual\">" >> "${HTML_FILE}"
            fi
            echo "${EPOCH}${NEW_VER_FULL}" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            echo "<td>" >> "${HTML_FILE}"
            echo "<a href=\"https://tracker.debian.org/pkg/${PACKAGE}\">DPT</a>" >> "${HTML_FILE}"
            echo "<a href=\"https://launchpad.net/ubuntu/+source/${PACKAGE}\">LP</a>" >> "${HTML_FILE}"
            echo "<a href=\"$(cat ${PKG_DIR}/README 2>/dev/null | grep \.git | head -n1 )\">GIT</a>" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            exit 0
        fi
    fi
}


# Print versions for unstable packages
PrintVersionsUnstable()
{
    if [ "${1}" = "print-versions" ]; then
        if [ -z "${2}" ]; then
            echo "File name must be not empty!"
            exit 1
        else
            HTML_FILE="${2}"
            echo "<td style=\"font-weight: bold;\">" >> "${HTML_FILE}"
            echo "${PACKAGE}" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            echo "<td>" >> "${HTML_FILE}"
            echo "${EPOCH}${OLD_VER_FULL}" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            if [ "${LAST_COMMIT}" != "${OLD_COMMIT}" ]; then
                echo "<td class=\"color-outdated\">" >> "${HTML_FILE}"
            else
                echo "<td class=\"color-actual\">" >> "${HTML_FILE}"
            fi
            echo "${EPOCH}${NEW_VER_FULL}" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            echo "<td>" >> "${HTML_FILE}"
            echo "<a href=\"https://tracker.debian.org/pkg/${PACKAGE}\">DPT</a>" >> "${HTML_FILE}"
            echo "<a href=\"https://launchpad.net/ubuntu/+source/${PACKAGE}\">LP</a>" >> "${HTML_FILE}"
            echo "<a href=\"$(cat ${PKG_DIR}/README 2>/dev/null | grep \.git | head -n1 )\">GIT</a>" >> "${HTML_FILE}"
            echo "</td>" >> "${HTML_FILE}"
            exit 0
        fi
    fi
}


# Check versions
CheckVersions()
{
    if [ -z "${NEW_VER}" ]; then
        echo "NEW_VER is empty!";
        exit 1;
    elif [ -z "${EPOCH}${OLD_VER_FULL}" ]; then
        echo "OLD_VER_FULL is empty!";
        exit 1;
    elif [ "${EPOCH}${NEW_VER_FULL}" = "${EPOCH}${OLD_VER_FULL}" ]; then
        echo "Upgrading is not required.";
        exit 0;
    else
        if [ "${NEW_VER}" != "${OLD_VER}" ]; then
            if [ "${SFX}" != "${DEFAULT_SFX}" ]; then
                echo "Now SFX = ${SFX} but must be '${DEFAULT_SFX}' for a new release!";
                exit 0;
            fi
        else
            if [ "${SFX}" = "${DEFAULT_SFX}" ]; then
                echo "Now SFX = ${SFX} but OLD_SFX = ${OLD_SFX}.";
                echo "Upgrading is not required.";
                exit 0;
            fi
        fi
    fi
}


# Check versions for unstable packages
CheckVersionsUnstable()
{
    if [ -z "${OLD_COMMIT}" ]; then
        echo "OLD_COMMIT is empty!";
        exit 1;
    elif [ -z "${LAST_COMMIT}" ]; then
        echo "LAST_COMMIT is empty!";
        exit 1;
    elif [ -z ${CUR_VER} ]; then
        echo "CUR_VER is empty!";
        exit 1;
    else
        if [ "${LAST_COMMIT}" != "${OLD_COMMIT}" ]; then
            if [ "${SFX}" != "${DEFAULT_SFX}" ]; then
                echo "Now SFX = ${SFX} but must be '${DEFAULT_SFX}' for a new release!";
                exit 0;
            fi
        else
            if [ "${SFX}" = "${DEFAULT_SFX}" ]; then
                echo "Upgrading is not required.";
                exit 0;
            fi
        fi
    fi
}

# Get sources using Makefile
GetSources()
{
    if [ ! -e "${PACKAGE}_${NEW_VER}.orig.tar.${A_TYPE}" ]; then
        "${PKG_DIR}/${PACKAGE}-debian/debian/rules" "get-orig-source"
    fi
}

# Get sources using uscan
GetSourcesUsingUscan()
{
    if [ ! -e "${PACKAGE}_${NEW_VER}.orig.tar.${A_TYPE}" ]; then
        uscan "${PKG_DIR}/${PACKAGE}-debian" \
              --download-version="${NEW_VER}" \
              --destdir "${TEMP_DIR}" \
              --rename || true
        rm -rf "${PKG_DIR}"/${PACKAGE}?${NEW_VER}* \
               "${PKG_DIR}"/${PACKAGE}_${OLD_VER_FULL}*
    fi
}

CheckBasicVariables()
{
    if [ -z "${PACKAGE}" ]; then
        echo "Error: PACKAGE variable is empty!";
        exit 1;
    elif [ -z "${NEW_VER}" ]; then
        echo "Error: NEW_VER variable is empty!";
        exit 1;
    fi
}

CheckTarballAvailability()
{
    if [ ! -e "${PACKAGE}_${NEW_VER}.orig.tar.${A_TYPE}" ]; then
        echo "File ${PACKAGE}_${NEW_VER}.orig.tar.${A_TYPE} is not found.";
        exit 1;
    fi
}

DefineTarOptions()
{
    case "${A_TYPE}" in
    "gz")
        export D_ARGS="xzf"
    ;;
    "bz2")
        export D_ARGS="xjf"
    ;;
    "xz")
        export D_ARGS="xJf"
    ;;
    *)
        echo "Tarball type is undefined!"
        exit 1
    ;;
    esac
}

DefineAdditionalVariables()
{
    if [ -z "${DIR_NAME}" ]; then
        export DIR_NAME="${PACKAGE}-${NEW_VER}"
    fi

    if [ -z "${OLD_DIR_NAME}" ]; then
        export OLD_DIR_NAME="${PACKAGE}-${OLD_VER}"
    fi

    if [ "${1}" = "clean" ]; then
        export CLEAN_BUILD="true"
    elif [ "${1}" = "fast" ]; then
        export FAST_UPLOAD="true"
    fi

    if [ "${2}" = "new" ]; then
        export TARGETED_TO_NEW_QUEUE="true"
    fi
    
    if [ -z "${DESTINATION}" ]; then
        export DESTINATION="tehnick"
    fi
}

OpenChangeLog()
{
    kwrite debian/changelog &> /dev/null
}

OpenTerminal()
{
    konsole &> /dev/null &
}

CopyUpdatedChangelogToGit()
{
    cd "${TEMP_DIR}"
    cp -fr "${DIR_NAME}/debian" "${PKG_DIR}/${PACKAGE}-debian/"
}

ReportStartOfUpdate()
{
    echo "Updating is started."
}

ReportBuildSuccess()
{
    echo "Update finished successfully!"
}

PrepareSourcePackage()
{
    rm -rf "${DIR_NAME}" "${PACKAGE}_${NEW_VER}-"*
    tar "${D_ARGS}" "${PACKAGE}_${NEW_VER}.orig.tar.${A_TYPE}"
    rm -rf "${DIR_NAME}/debian"
    cp -rf "${PKG_DIR}/${PACKAGE}-debian/debian" "${DIR_NAME}/debian"
}

PrepareDiff()
{
    cd "${TEMP_DIR}" || exit 1

    if [ -d "${OLD_DIR_NAME}" ] && [ "${SFX}" = "${DEFAULT_SFX}" ]; then
        diff -urN "${OLD_DIR_NAME}" "${DIR_NAME}" > \
                  "${TEMP_DIR}/__${PACKAGE}_${OLD_VER_FULL}::${NEW_VER_FULL}.diff"
    fi
}

CheckAvailableVersions()
{
    cd "${TEMP_DIR}/${DIR_NAME}" || exit 1

    echo ;
    echo "Uscan:"
    uscan --report-status
    echo ;
}

MakeSourcePackage()
{
    cd "${TEMP_DIR}/${DIR_NAME}" || exit 1

    # --buildinfo-option="-O" is temporary workaround.
    # See: https://bugs.debian.org/853795#10
    # debuild -S -sa -d --buildinfo-option="-O" || exit 1
    debuild -S -sa -d || exit 1
}

UpdateSourcePackage()
{
    cd "${TEMP_DIR}/${DIR_NAME}" || exit 1

    if [ "${SFX}" = "${DEFAULT_SFX}" ]; then
        dch -b --force-distribution --distribution "${MAIN_DIST}" \
            -v "${EPOCH}${NEW_VER_FULL}" \
            "${UPDATE_STRING}"

        OpenChangeLog
        MakeSourcePackage
    else
        export UPDATE_STRING="Some fixes in package."
        dch -b --force-distribution --distribution "${MAIN_DIST}" \
            -v "${EPOCH}${NEW_VER_FULL}" \
            "${UPDATE_STRING}"

        OpenChangeLog
        # debuild -S -sd --buildinfo-option="-O" || exit 1
        MakeSourcePackage
    fi
}

UpdateSourcePackagesForLaunchpad()
{
    cd "${TEMP_DIR}/${DIR_NAME}" || exit 1

    # begin update for main verion of Ubuntu
    export DIST="${MAIN_DIST}"
    if [ "${SFX}" = "${DEFAULT_SFX}" ]; then
        dch -b --force-distribution --distribution "${DIST}" \
            -v "${EPOCH}${NEW_VER}${SFX}~${DIST}1" \
            "${UPDATE_STRING}"

        [ "${EDIT_CHANGELOG}" = "true" ] && OpenChangeLog
        debuild -S -sa -d --buildinfo-option="-O" || exit 1
    else
        export UPDATE_STRING="Small improvements in the package."
        dch -b --force-distribution --distribution "${DIST}" \
            -v "${EPOCH}${NEW_VER}${SFX}~${DIST}1" \
            "${UPDATE_STRING}"

        OpenChangeLog
        debuild -S -sa -d --buildinfo-option="-O" || exit 1
    fi
    # end update for main verion of Ubuntu

    # begin update for older releases of Ubuntu
    cp -f debian/changelog ../changelog # copy basic changelog

    for DIST in ${DIST_LIST} ; do
        cp -f ../changelog debian/changelog
        export UPDATE_STRING="Automatic backport to ${DIST}; no changes required."
        dch -b --force-distribution --distribution "${DIST}" \
            -v "${EPOCH}${NEW_VER}${SFX}~${DIST}1" \
            "${UPDATE_STRING}"

        debuild -S -sd -d --buildinfo-option="-O" || exit 1
    done

    mv ../changelog debian/changelog # rollback basic changelog
    # end update for older releases of Ubuntu
}

CheckPackageBuild()
{
    if [ "${CLEAN_BUILD}" = "true" ]; then
        sudo rm -rf "${TEST_DIR}"/*
    else
        rm -rf "${TEST_DIR}"/*
    fi

    mkdir -p "${TEST_DIR}"
    cd "${TEST_DIR}" || exit 1

    cp -a "${TEMP_DIR}/${DIR_NAME}" "${TEST_DIR}/"
    cp -f "${TEMP_DIR}/${PACKAGE}_${NEW_VER}.orig.tar."* "${TEST_DIR}/"
    cp -f "${TEMP_DIR}/${PACKAGE}_${NEW_VER_FULL}.debian.tar."* "${TEST_DIR}/"
    cp -f "${TEMP_DIR}/${PACKAGE}_${NEW_VER_FULL}.dsc" "${TEST_DIR}/"

    export BUILD_LOG_FILE="${TEMP_DIR}/__${PACKAGE}-${NEW_VER_FULL}.build.log"
    export WARNINGS_LOG_FILE="${TEMP_DIR}/__${PACKAGE}-${NEW_VER_FULL}.warnings.log"
    echo ;

    cd "${TEST_DIR}/${DIR_NAME}"
    echo "Start building packages..."
    if [ "${CLEAN_BUILD}" = "true" ]; then
        sudo time nice -n19 pdebuild --pbuilder cowbuilder \
                                     --buildresult "${TEST_DIR}" \
                                     > ${BUILD_LOG_FILE} \
                                     2> ${WARNINGS_LOG_FILE} || exit 1
        sudo chown -R "${SUDO_USER}:${SUDO_USER}" "${TEST_DIR}"
    else
        time nice -n19 dpkg-buildpackage -rfakeroot -uc -us \
                                         > ${BUILD_LOG_FILE} \
                                         2> ${WARNINGS_LOG_FILE} || exit 1
    fi
    cat  ${WARNINGS_LOG_FILE}
    echo "Finished building packages."
    echo ;
}

CheckPackageUsingLintian()
{
    cd "${TEST_DIR}" || exit 1

    export LINTIAN_LOG_FILE="${TEMP_DIR}/__${PACKAGE}-${NEW_VER_FULL}.lintian.log"
    echo ;
    echo "Now running lintian:"
    # --profile ubuntu
    time nice -n19 lintian -ivIE --pedantic ${PACKAGE}_${NEW_VER_FULL}_*.changes > ${LINTIAN_LOG_FILE}
    grep "E: " "${LINTIAN_LOG_FILE}"
    grep "W: " "${LINTIAN_LOG_FILE}"
    grep "I: " "${LINTIAN_LOG_FILE}"
    grep "P: " "${LINTIAN_LOG_FILE}"
    grep "X: " "${LINTIAN_LOG_FILE}"
    echo "Finished running lintian."
    echo ;
    kwrite ${LINTIAN_LOG_FILE} &> /dev/null
}

DoMainChecks()
{
    if [ "${FAST_UPLOAD}" = "true" ]; then
        echo ;
        echo "Fast upload (without tests)."
        echo ;
    else
        echo ;
        echo "Now will be tests."
        echo ;

        CheckPackageBuild
        CheckPackageUsingLintian

        cd "${TEMP_DIR}/${DIR_NAME}"
    fi
}

SignChangesFile()
{
    ARCHITECTURE="$(dpkg --print-architecture)"
    debsign "${PACKAGE}_${NEW_VER_FULL}_${ARCHITECTURE}.changes"
}

ShowPromptForPackageUpload()
{
    if [ "${TARGETED_TO_NEW_QUEUE}" = "true" ]; then
        cd "${TEST_DIR}"
        SignChangesFile
        echo "Package is targeted into NEW queue, so binary upload is required:"
        echo "dput -f ftp-eu ${PACKAGE}_${NEW_VER_FULL}_${ARCHITECTURE}.changes"
    else
        cd "${TEMP_DIR}"
        echo "Sorce-only upload:"
        echo "dput -f ftp-eu ${PACKAGE}_${NEW_VER_FULL}_source.changes"
    fi
}

UploadPackagesToLaunchpad()
{
    cd "${TEMP_DIR}"
    for DIST in ${MAIN_DIST} ${DIST_LIST} ; do
        dput -f ${DESTINATION} ${PACKAGE}_${NEW_VER}${SFX}~${DIST}1_source.changes
    done
}

UpdateLocalRepo()
{
    if [ "${FAST_UPLOAD}" != "true" ]; then
        export APT_DIR="${MAIN_DIR}/LocalRepo"
        mkdir -p "${APT_DIR}/${PACKAGE}/"
        rm -f "${APT_DIR}/${PACKAGE}"/*.deb
        cp -f "${TEST_DIR}"/*.deb "${APT_DIR}/${PACKAGE}/"
        cd "${APT_DIR}/" || exit 1
        rm -f Packages* InRelease* Release*
        apt-ftparchive packages . > Packages
        gzip -c Packages > Packages.gz
        gpg -abs -o Packages.gpg Packages.gz
    fi
}

