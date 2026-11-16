// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCourseCollectionCollection on Isar {
  IsarCollection<CourseCollection> get courseCollections => this.collection();
}

const CourseCollectionSchema = CollectionSchema(
  name: r'CourseCollection',
  id: 5083647957483466380,
  properties: {
    r'courseCode': PropertySchema(
      id: 0,
      name: r'courseCode',
      type: IsarType.string,
    ),
    r'courseName': PropertySchema(
      id: 1,
      name: r'courseName',
      type: IsarType.string,
    ),
    r'credits': PropertySchema(
      id: 2,
      name: r'credits',
      type: IsarType.long,
    ),
    r'lecturer': PropertySchema(
      id: 3,
      name: r'lecturer',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _courseCollectionEstimateSize,
  serialize: _courseCollectionSerialize,
  deserialize: _courseCollectionDeserialize,
  deserializeProp: _courseCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'courseCode': IndexSchema(
      id: -3801750468446762910,
      name: r'courseCode',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'courseCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _courseCollectionGetId,
  getLinks: _courseCollectionGetLinks,
  attach: _courseCollectionAttach,
  version: '3.1.0+1',
);

int _courseCollectionEstimateSize(
  CourseCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.courseCode.length * 3;
  bytesCount += 3 + object.courseName.length * 3;
  bytesCount += 3 + object.lecturer.length * 3;
  return bytesCount;
}

void _courseCollectionSerialize(
  CourseCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.courseCode);
  writer.writeString(offsets[1], object.courseName);
  writer.writeLong(offsets[2], object.credits);
  writer.writeString(offsets[3], object.lecturer);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

CourseCollection _courseCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CourseCollection();
  object.courseCode = reader.readString(offsets[0]);
  object.courseName = reader.readString(offsets[1]);
  object.credits = reader.readLong(offsets[2]);
  object.id = id;
  object.lecturer = reader.readString(offsets[3]);
  object.updatedAt = reader.readDateTime(offsets[4]);
  return object;
}

P _courseCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _courseCollectionGetId(CourseCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _courseCollectionGetLinks(CourseCollection object) {
  return [];
}

void _courseCollectionAttach(
    IsarCollection<dynamic> col, Id id, CourseCollection object) {
  object.id = id;
}

extension CourseCollectionByIndex on IsarCollection<CourseCollection> {
  Future<CourseCollection?> getByCourseCode(String courseCode) {
    return getByIndex(r'courseCode', [courseCode]);
  }

  CourseCollection? getByCourseCodeSync(String courseCode) {
    return getByIndexSync(r'courseCode', [courseCode]);
  }

  Future<bool> deleteByCourseCode(String courseCode) {
    return deleteByIndex(r'courseCode', [courseCode]);
  }

  bool deleteByCourseCodeSync(String courseCode) {
    return deleteByIndexSync(r'courseCode', [courseCode]);
  }

  Future<List<CourseCollection?>> getAllByCourseCode(
      List<String> courseCodeValues) {
    final values = courseCodeValues.map((e) => [e]).toList();
    return getAllByIndex(r'courseCode', values);
  }

  List<CourseCollection?> getAllByCourseCodeSync(
      List<String> courseCodeValues) {
    final values = courseCodeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'courseCode', values);
  }

  Future<int> deleteAllByCourseCode(List<String> courseCodeValues) {
    final values = courseCodeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'courseCode', values);
  }

  int deleteAllByCourseCodeSync(List<String> courseCodeValues) {
    final values = courseCodeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'courseCode', values);
  }

  Future<Id> putByCourseCode(CourseCollection object) {
    return putByIndex(r'courseCode', object);
  }

  Id putByCourseCodeSync(CourseCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'courseCode', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCourseCode(List<CourseCollection> objects) {
    return putAllByIndex(r'courseCode', objects);
  }

  List<Id> putAllByCourseCodeSync(List<CourseCollection> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'courseCode', objects, saveLinks: saveLinks);
  }
}

extension CourseCollectionQueryWhereSort
    on QueryBuilder<CourseCollection, CourseCollection, QWhere> {
  QueryBuilder<CourseCollection, CourseCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CourseCollectionQueryWhere
    on QueryBuilder<CourseCollection, CourseCollection, QWhereClause> {
  QueryBuilder<CourseCollection, CourseCollection, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterWhereClause>
      courseCodeEqualTo(String courseCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'courseCode',
        value: [courseCode],
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterWhereClause>
      courseCodeNotEqualTo(String courseCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseCode',
              lower: [],
              upper: [courseCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseCode',
              lower: [courseCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseCode',
              lower: [courseCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'courseCode',
              lower: [],
              upper: [courseCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CourseCollectionQueryFilter
    on QueryBuilder<CourseCollection, CourseCollection, QFilterCondition> {
  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courseCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courseCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courseName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseName',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      courseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courseName',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      creditsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credits',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      creditsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credits',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      creditsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credits',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      creditsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lecturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lecturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lecturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lecturer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lecturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lecturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lecturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lecturer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lecturer',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      lecturerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lecturer',
        value: '',
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CourseCollectionQueryObject
    on QueryBuilder<CourseCollection, CourseCollection, QFilterCondition> {}

extension CourseCollectionQueryLinks
    on QueryBuilder<CourseCollection, CourseCollection, QFilterCondition> {}

extension CourseCollectionQuerySortBy
    on QueryBuilder<CourseCollection, CourseCollection, QSortBy> {
  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByCourseCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByCourseCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByCourseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByCourseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByCreditsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByLecturer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lecturer', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByLecturerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lecturer', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CourseCollectionQuerySortThenBy
    on QueryBuilder<CourseCollection, CourseCollection, QSortThenBy> {
  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByCourseCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByCourseCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByCourseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByCourseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByCreditsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credits', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByLecturer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lecturer', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByLecturerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lecturer', Sort.desc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CourseCollectionQueryWhereDistinct
    on QueryBuilder<CourseCollection, CourseCollection, QDistinct> {
  QueryBuilder<CourseCollection, CourseCollection, QDistinct>
      distinctByCourseCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QDistinct>
      distinctByCourseName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QDistinct>
      distinctByCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credits');
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QDistinct>
      distinctByLecturer({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lecturer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CourseCollection, CourseCollection, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CourseCollectionQueryProperty
    on QueryBuilder<CourseCollection, CourseCollection, QQueryProperty> {
  QueryBuilder<CourseCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CourseCollection, String, QQueryOperations>
      courseCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseCode');
    });
  }

  QueryBuilder<CourseCollection, String, QQueryOperations>
      courseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseName');
    });
  }

  QueryBuilder<CourseCollection, int, QQueryOperations> creditsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credits');
    });
  }

  QueryBuilder<CourseCollection, String, QQueryOperations> lecturerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lecturer');
    });
  }

  QueryBuilder<CourseCollection, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
