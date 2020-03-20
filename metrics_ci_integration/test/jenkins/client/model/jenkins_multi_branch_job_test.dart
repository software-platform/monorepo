import 'package:ci_integration/jenkins/client/model/jenkins_job.dart';
import 'package:ci_integration/jenkins/client/model/jenkins_multi_branch_job.dart';
import 'package:test/test.dart';

void main() {
  group("JenkinsMultiBranchJob", () {
    const multiBranchJobJson = {
      'name': 'name',
      'fullName': 'fullName',
      'url': 'url',
      'jobs': [
        {
          'name': 'subjob',
          'fullName': 'job/subjob',
          'url': 'url',
        },
      ],
    };

    const multiBranchJob = JenkinsMultiBranchJob(
      name: 'name',
      fullName: 'fullName',
      url: 'url',
      jobs: [
        JenkinsJob(
          name: 'subjob',
          fullName: 'job/subjob',
          url: 'url',
        ),
      ],
    );

    test(".fromJson() should return null if the given json is null", () {
      final job = JenkinsMultiBranchJob.fromJson(null);

      expect(job, isNull);
    });

    test(".fromJson() should create an instance from the json map", () {
      final job = JenkinsMultiBranchJob.fromJson(multiBranchJobJson);

      expect(job, equals(multiBranchJob));
    });

    test(".toJson() should populate a json map with a list of jobs", () {
      const job = JenkinsMultiBranchJob(name: 'name', jobs: []);
      final json = job.toJson();

      expect(json, containsPair('jobs', isEmpty));
    });

    test(".toJson() should convert an instance to the json map", () {
      final json = multiBranchJob.toJson();

      expect(json, equals(multiBranchJobJson));
    });
  });
}
