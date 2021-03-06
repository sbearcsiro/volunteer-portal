package au.org.ala.volunteer

import au.org.ala.volunteer.collectory.CollectoryDto
import au.org.ala.volunteer.collectory.CollectoryProviderDto
import org.apache.commons.io.FileUtils
import org.springframework.web.multipart.MultipartFile

class InstitutionService {

    def grailsApplication
    def collectoryClient
    def grailsLinkGenerator

    private boolean uploadtoLocalPathFromUrl(String url, String localPath) {
        if (url && localPath) {
            try {
                FileUtils.copyURLToFile(new URL(url), new File(localPath), 30 * 1000, 30 * 1000)
                return true
            } catch (Exception ex) {
                log.error("Failed to transfer image file from url for institution", ex)
            }
        }
        return false
    }

    public uploadImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getImagePath(institution.id))
    }

    public uploadBannerImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getBannerImagePath(institution.id))
    }

    public uploadLogoImageFromUrl(Institution institution, String url) {
        uploadtoLocalPathFromUrl(url, getLogoImagePath(institution.id))
    }

    public clearImage(Institution institution) {
        deleteLocalFile(getImagePath(institution.id))
    }

    public clearLogo(Institution institution) {
        deleteLocalFile(getLogoImagePath(institution.id))
    }

    public clearBanner(Institution institution) {
        deleteLocalFile(getBannerImagePath(institution.id))
    }

    private static deleteLocalFile(String filename) {
        if (filename) {
            def file = new File(filename)
            if (file.exists()) {
                file.delete()
                return true
            }
        }
        return false
    }


    private boolean uploadToLocalPath(MultipartFile mpfile, String localFile) {
        if (!mpfile) {
            return false
        }

        try {
            def file = new File(localFile);
            if (!file.getParentFile().exists()) {
                if (!file.getParentFile().mkdirs()) {
                    throw new RuntimeException("Failed to create institution directories: ${file.getParentFile().getAbsolutePath()}")
                }
            }
            mpfile.transferTo(file);
            return true
        } catch (Exception ex) {
            log.error("Failed to upload image file for institution", ex)
        }
    }

    public uploadImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getImagePath(institution?.id))
    }

    public uploadBannerImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getBannerImagePath(institution.id))
    }

    public uploadLogoImage(Institution institution, MultipartFile mpfile) {
        uploadToLocalPath(mpfile, getLogoImagePath(institution.id))
    }

    public boolean hasImage(Institution institution) {
        def f = new File(getImagePath(institution?.id))
        return f.exists()
    }

    public boolean hasBannerImage(Institution institution) {
        def f = new File(getBannerImagePath(institution?.id))
        return f.exists()
    }

    public boolean hasLogoImage(Institution institution) {
        def f = new File(getLogoImagePath(institution?.id))
        return f.exists()
    }

    public String getImageUrl(Institution institution) {
        if (hasImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/image.jpg"
        } else {
            return grailsLinkGenerator.resource([dir: '/images/banners', file: 'default-institution-image.jpg'])
        }
    }

    public String getBannerImageUrl(Institution institution) {
        if (hasBannerImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/banner-image.jpg"
        }
    }

    public String getLogoImageUrl(Institution institution) {
        if (hasLogoImage(institution)) {
            return "${grailsApplication.config.server.url}/${grailsApplication.config.images.urlPrefix}institution/${institution.id}/logo-image.jpg"
        } else {
            return grailsLinkGenerator.resource([dir: '/images/banners', file: 'default-institution-logo.png'])
        }
    }

    private String getImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/image.jpg"
    }

    private String getBannerImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/banner-image.jpg"
    }

    private String getLogoImagePath(long institutionId) {
        return "${grailsApplication.config.images.home}/institution/${institutionId}/logo-image.jpg"
    }


    public CollectoryProviderDto getCollectoryObjectFromUid(String uid) {

        CollectoryProviderDto provider = null
        if (uid?.toLowerCase()?.startsWith("in")) {
            provider = collectoryClient.getInstitution("$uid")
        } else if (uid?.toLowerCase()?.startsWith("co")) {
            provider = collectoryClient.getCollection("$uid")
        }

        return provider
    }

    public List<CollectoryDto> getCombinedInsitutionsAndCollections() {
        def results = collectoryClient.getInstitutions()
        def collections = collectoryClient.getCollections()
        // Merge the two lists
        results.addAll(collections)
        results.sort { it.name }

        return results
    }


    Institution findByIdOrName(Long id, String name) {
        Institution retVal
        if (id)  {
            retVal = Institution.get(id)
        } else {
            try {
               retVal = Institution.findByName(name)
            } catch (Exception e) {
                log.error("Exception", e)
                throw e
            }
        }
        return retVal
    }

    /**
     * Returns a map of project counts, keyed by institution
     *
     * @param institutions
     */
    def getProjectCounts(List<Institution> institutions, boolean includeDeactivated = false) {

        if (!institutions) {
            return [:]
        }

       def c = Project.createCriteria()
        def results = c.list {
            'in'("institution", institutions)
            if (!includeDeactivated) {
                or {
                    isNull("inactive")
                    eq("inactive", false)
                }
            }
            projections {
                groupProperty("institution")
                count("id")
            }
        }

        return results.collectEntries {
            [it[0], it[1]]
        }
    }

    Long getTranscriberCount(Institution institution) {
        Task.executeQuery("select count(distinct fullyTranscribedBy) from Task where project.institution = :institution", [institution: institution]).get(0)
    }

    Map<String, Map<String, Long>> getProjectTypeCounts(Institution institution, boolean includeDeactivated = false) {
        final tasks = Task.executeQuery("select new map(project.id as projId, project.projectType.label as label, fullyTranscribedBy as ft, fullyValidatedBy as fv) from Task where project.institution = :institution and ((project.inactive is null) or (project.inactive is not null and (project.inactive = :incDe or :incDe = true)))", [institution: institution, incDe: includeDeactivated])

        // Do this to ensure projects with 0 tasks still get counted
        final projectCountByProjectType = Project.executeQuery("select projectType.label, count(id) from Project where institution = :institution and ((inactive is null) or (inactive is not null and (inactive = :incDe or :incDe = true))) group by projectType.label", [institution: institution, incDe: includeDeactivated])

        final accumulator = projectCountByProjectType.collectEntries {
            final result = [:]
            final key = it.length > 1 ? it[0] ?: 'None' : 'None'
            final total = it.length > 1 ? it[1] : it[0]
            result.put(key, [complete: 0, started: 0, total: total])
            result
        }

        final groups = tasks.groupBy([{ it.label }, { it.projId }])

        final projectTypeCounts = groups.inject(accumulator) { acc, val ->
            final key = val.key ?: 'None'
            final result = acc.get(key)
            val.value.each { projTaskList ->
                if (projTaskList.value.every { it.fv }) result.complete++
                else if (projTaskList.value.any { it.fv || it.ft }) result.started++
            }
            acc
        }

        return projectTypeCounts
    }

    TaskCounts getTaskCounts(Institution institution) {
        def totalTasks = countTasksForInstitution(institution)
        def transcribedTasks = countTranscribedTasksForInstitution(institution)
        def validatedTasks = countValidatedTasksForInstitution(institution)
        new TaskCounts(taskCount: totalTasks, transcribedCount: transcribedTasks, validatedCount: validatedTasks)
    }

    int countTasksForInstitution(Institution institution) {
        Task.executeQuery("select count(*) from Task where project.institution = :institution", [institution: institution])?.get(0)
    }

    int countTranscribedTasksForInstitution(Institution institution) {
        Task.executeQuery("select count(*) from Task where fullyTranscribedBy is not null and project.institution = :institution", [institution: institution])?.get(0)
    }

    int countValidatedTasksForInstitution(Institution institution) {
        Task.executeQuery("select count(*) from Task where fullyValidatedBy is not null and project.institution = :institution", [institution: institution])?.get(0)
    }

}
