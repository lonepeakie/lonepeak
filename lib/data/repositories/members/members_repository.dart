import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/utils/result.dart';

abstract class MembersRepository {
  Future<Result<List<Member>>> getMembers();
  Future<Result<Member>> getMemberById(String id);
  Future<Result<void>> addMember(Member member);
  Future<Result<void>> updateMember(Member member);
  Future<Result<void>> deleteMember(String id);
}
