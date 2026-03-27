// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDocumentEntityCollection on Isar {
  IsarCollection<DocumentEntity> get documentEntitys => this.collection();
}

const DocumentEntitySchema = CollectionSchema(
  name: r'DocumentEntity',
  id: 5395616779084000924,
  properties: {
    r'collectionId': PropertySchema(
      id: 0,
      name: r'collectionId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'documentId': PropertySchema(
      id: 2,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 3,
      name: r'status',
      type: IsarType.byte,
      enumMap: _DocumentEntitystatusEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _documentEntityEstimateSize,
  serialize: _documentEntitySerialize,
  deserialize: _documentEntityDeserialize,
  deserializeProp: _documentEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'collectionId': IndexSchema(
      id: -7489395134515229581,
      name: r'collectionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collectionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'pages': LinkSchema(
      id: 2730244151953831128,
      name: r'pages',
      target: r'PageEntity',
      single: false,
    ),
    r'tags': LinkSchema(
      id: -3465904111451310132,
      name: r'tags',
      target: r'TagEntity',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _documentEntityGetId,
  getLinks: _documentEntityGetLinks,
  attach: _documentEntityAttach,
  version: '3.1.0+1',
);

int _documentEntityEstimateSize(
  DocumentEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.collectionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _documentEntitySerialize(
  DocumentEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.collectionId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.documentId);
  writer.writeByte(offsets[3], object.status.index);
  writer.writeString(offsets[4], object.title);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

DocumentEntity _documentEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DocumentEntity();
  object.collectionId = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.documentId = reader.readString(offsets[2]);
  object.id = id;
  object.status =
      _DocumentEntitystatusValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          DocumentStatus.draft;
  object.title = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _documentEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (_DocumentEntitystatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          DocumentStatus.draft) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DocumentEntitystatusEnumValueMap = {
  'draft': 0,
  'ready': 1,
  'archived': 2,
};
const _DocumentEntitystatusValueEnumMap = {
  0: DocumentStatus.draft,
  1: DocumentStatus.ready,
  2: DocumentStatus.archived,
};

Id _documentEntityGetId(DocumentEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _documentEntityGetLinks(DocumentEntity object) {
  return [object.pages, object.tags];
}

void _documentEntityAttach(
    IsarCollection<dynamic> col, Id id, DocumentEntity object) {
  object.id = id;
  object.pages.attach(col, col.isar.collection<PageEntity>(), r'pages', id);
  object.tags.attach(col, col.isar.collection<TagEntity>(), r'tags', id);
}

extension DocumentEntityByIndex on IsarCollection<DocumentEntity> {
  Future<DocumentEntity?> getByDocumentId(String documentId) {
    return getByIndex(r'documentId', [documentId]);
  }

  DocumentEntity? getByDocumentIdSync(String documentId) {
    return getByIndexSync(r'documentId', [documentId]);
  }

  Future<bool> deleteByDocumentId(String documentId) {
    return deleteByIndex(r'documentId', [documentId]);
  }

  bool deleteByDocumentIdSync(String documentId) {
    return deleteByIndexSync(r'documentId', [documentId]);
  }

  Future<List<DocumentEntity?>> getAllByDocumentId(
      List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'documentId', values);
  }

  List<DocumentEntity?> getAllByDocumentIdSync(List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'documentId', values);
  }

  Future<int> deleteAllByDocumentId(List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'documentId', values);
  }

  int deleteAllByDocumentIdSync(List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'documentId', values);
  }

  Future<Id> putByDocumentId(DocumentEntity object) {
    return putByIndex(r'documentId', object);
  }

  Id putByDocumentIdSync(DocumentEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'documentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDocumentId(List<DocumentEntity> objects) {
    return putAllByIndex(r'documentId', objects);
  }

  List<Id> putAllByDocumentIdSync(List<DocumentEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'documentId', objects, saveLinks: saveLinks);
  }
}

extension DocumentEntityQueryWhereSort
    on QueryBuilder<DocumentEntity, DocumentEntity, QWhere> {
  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DocumentEntityQueryWhere
    on QueryBuilder<DocumentEntity, DocumentEntity, QWhereClause> {
  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause>
      collectionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [null],
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause>
      collectionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'collectionId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause>
      collectionIdEqualTo(String? collectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [collectionId],
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterWhereClause>
      collectionIdNotEqualTo(String? collectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DocumentEntityQueryFilter
    on QueryBuilder<DocumentEntity, DocumentEntity, QFilterCondition> {
  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'collectionId',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'collectionId',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      collectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
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

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
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

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      statusEqualTo(DocumentStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      statusGreaterThan(
    DocumentStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      statusLessThan(
    DocumentStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      statusBetween(
    DocumentStatus lower,
    DocumentStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
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

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
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

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
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

extension DocumentEntityQueryObject
    on QueryBuilder<DocumentEntity, DocumentEntity, QFilterCondition> {}

extension DocumentEntityQueryLinks
    on QueryBuilder<DocumentEntity, DocumentEntity, QFilterCondition> {
  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition> pages(
      FilterQuery<PageEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'pages');
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      pagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pages', length, true, length, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      pagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pages', 0, true, 0, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      pagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pages', 0, false, 999999, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      pagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pages', 0, true, length, include);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      pagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pages', length, include, 999999, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      pagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'pages', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition> tags(
      FilterQuery<TagEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tags');
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'tags', lower, includeLower, upper, includeUpper);
    });
  }
}

extension DocumentEntityQuerySortBy
    on QueryBuilder<DocumentEntity, DocumentEntity, QSortBy> {
  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      sortByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      sortByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension DocumentEntityQuerySortThenBy
    on QueryBuilder<DocumentEntity, DocumentEntity, QSortThenBy> {
  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      thenByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      thenByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension DocumentEntityQueryWhereDistinct
    on QueryBuilder<DocumentEntity, DocumentEntity, QDistinct> {
  QueryBuilder<DocumentEntity, DocumentEntity, QDistinct>
      distinctByCollectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QDistinct> distinctByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentEntity, DocumentEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension DocumentEntityQueryProperty
    on QueryBuilder<DocumentEntity, DocumentEntity, QQueryProperty> {
  QueryBuilder<DocumentEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DocumentEntity, String?, QQueryOperations>
      collectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionId');
    });
  }

  QueryBuilder<DocumentEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DocumentEntity, String, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<DocumentEntity, DocumentStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DocumentEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<DocumentEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCollectionEntityCollection on Isar {
  IsarCollection<CollectionEntity> get collectionEntitys => this.collection();
}

const CollectionEntitySchema = CollectionSchema(
  name: r'CollectionEntity',
  id: 1279651062103045025,
  properties: {
    r'collectionId': PropertySchema(
      id: 0,
      name: r'collectionId',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _collectionEntityEstimateSize,
  serialize: _collectionEntitySerialize,
  deserialize: _collectionEntityDeserialize,
  deserializeProp: _collectionEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'collectionId': IndexSchema(
      id: -7489395134515229581,
      name: r'collectionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'collectionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _collectionEntityGetId,
  getLinks: _collectionEntityGetLinks,
  attach: _collectionEntityAttach,
  version: '3.1.0+1',
);

int _collectionEntityEstimateSize(
  CollectionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.collectionId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _collectionEntitySerialize(
  CollectionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.collectionId);
  writer.writeString(offsets[1], object.name);
}

CollectionEntity _collectionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CollectionEntity();
  object.collectionId = reader.readString(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  return object;
}

P _collectionEntityDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _collectionEntityGetId(CollectionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _collectionEntityGetLinks(CollectionEntity object) {
  return [];
}

void _collectionEntityAttach(
    IsarCollection<dynamic> col, Id id, CollectionEntity object) {
  object.id = id;
}

extension CollectionEntityByIndex on IsarCollection<CollectionEntity> {
  Future<CollectionEntity?> getByCollectionId(String collectionId) {
    return getByIndex(r'collectionId', [collectionId]);
  }

  CollectionEntity? getByCollectionIdSync(String collectionId) {
    return getByIndexSync(r'collectionId', [collectionId]);
  }

  Future<bool> deleteByCollectionId(String collectionId) {
    return deleteByIndex(r'collectionId', [collectionId]);
  }

  bool deleteByCollectionIdSync(String collectionId) {
    return deleteByIndexSync(r'collectionId', [collectionId]);
  }

  Future<List<CollectionEntity?>> getAllByCollectionId(
      List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'collectionId', values);
  }

  List<CollectionEntity?> getAllByCollectionIdSync(
      List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'collectionId', values);
  }

  Future<int> deleteAllByCollectionId(List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'collectionId', values);
  }

  int deleteAllByCollectionIdSync(List<String> collectionIdValues) {
    final values = collectionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'collectionId', values);
  }

  Future<Id> putByCollectionId(CollectionEntity object) {
    return putByIndex(r'collectionId', object);
  }

  Id putByCollectionIdSync(CollectionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'collectionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCollectionId(List<CollectionEntity> objects) {
    return putAllByIndex(r'collectionId', objects);
  }

  List<Id> putAllByCollectionIdSync(List<CollectionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'collectionId', objects, saveLinks: saveLinks);
  }

  Future<CollectionEntity?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  CollectionEntity? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<CollectionEntity?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<CollectionEntity?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(CollectionEntity object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(CollectionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<CollectionEntity> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<CollectionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension CollectionEntityQueryWhereSort
    on QueryBuilder<CollectionEntity, CollectionEntity, QWhere> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CollectionEntityQueryWhere
    on QueryBuilder<CollectionEntity, CollectionEntity, QWhereClause> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
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

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      collectionIdEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectionId',
        value: [collectionId],
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      collectionIdNotEqualTo(String collectionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [collectionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectionId',
              lower: [],
              upper: [collectionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterWhereClause>
      nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CollectionEntityQueryFilter
    on QueryBuilder<CollectionEntity, CollectionEntity, QFilterCondition> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      collectionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
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

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
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

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
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

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension CollectionEntityQueryObject
    on QueryBuilder<CollectionEntity, CollectionEntity, QFilterCondition> {}

extension CollectionEntityQueryLinks
    on QueryBuilder<CollectionEntity, CollectionEntity, QFilterCondition> {}

extension CollectionEntityQuerySortBy
    on QueryBuilder<CollectionEntity, CollectionEntity, QSortBy> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CollectionEntityQuerySortThenBy
    on QueryBuilder<CollectionEntity, CollectionEntity, QSortThenBy> {
  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCollectionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByCollectionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectionId', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CollectionEntityQueryWhereDistinct
    on QueryBuilder<CollectionEntity, CollectionEntity, QDistinct> {
  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct>
      distinctByCollectionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CollectionEntity, CollectionEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension CollectionEntityQueryProperty
    on QueryBuilder<CollectionEntity, CollectionEntity, QQueryProperty> {
  QueryBuilder<CollectionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CollectionEntity, String, QQueryOperations>
      collectionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectionId');
    });
  }

  QueryBuilder<CollectionEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPageEntityCollection on Isar {
  IsarCollection<PageEntity> get pageEntitys => this.collection();
}

const PageEntitySchema = CollectionSchema(
  name: r'PageEntity',
  id: 7780399719172098451,
  properties: {
    r'documentId': PropertySchema(
      id: 0,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'hasSignature': PropertySchema(
      id: 1,
      name: r'hasSignature',
      type: IsarType.bool,
    ),
    r'height': PropertySchema(
      id: 2,
      name: r'height',
      type: IsarType.long,
    ),
    r'order': PropertySchema(
      id: 3,
      name: r'order',
      type: IsarType.long,
    ),
    r'pageId': PropertySchema(
      id: 4,
      name: r'pageId',
      type: IsarType.string,
    ),
    r'processedImagePath': PropertySchema(
      id: 5,
      name: r'processedImagePath',
      type: IsarType.string,
    ),
    r'rawImagePath': PropertySchema(
      id: 6,
      name: r'rawImagePath',
      type: IsarType.string,
    ),
    r'signatureImagePath': PropertySchema(
      id: 7,
      name: r'signatureImagePath',
      type: IsarType.string,
    ),
    r'signatureScale': PropertySchema(
      id: 8,
      name: r'signatureScale',
      type: IsarType.double,
    ),
    r'signatureX': PropertySchema(
      id: 9,
      name: r'signatureX',
      type: IsarType.double,
    ),
    r'signatureY': PropertySchema(
      id: 10,
      name: r'signatureY',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'width': PropertySchema(
      id: 12,
      name: r'width',
      type: IsarType.long,
    )
  },
  estimateSize: _pageEntityEstimateSize,
  serialize: _pageEntitySerialize,
  deserialize: _pageEntityDeserialize,
  deserializeProp: _pageEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'pageId': IndexSchema(
      id: 3928962759474932809,
      name: r'pageId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'pageId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'ocrBlocks': LinkSchema(
      id: 4115501896272982577,
      name: r'ocrBlocks',
      target: r'OcrBlockEntity',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _pageEntityGetId,
  getLinks: _pageEntityGetLinks,
  attach: _pageEntityAttach,
  version: '3.1.0+1',
);

int _pageEntityEstimateSize(
  PageEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.pageId.length * 3;
  bytesCount += 3 + object.processedImagePath.length * 3;
  bytesCount += 3 + object.rawImagePath.length * 3;
  {
    final value = object.signatureImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _pageEntitySerialize(
  PageEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.documentId);
  writer.writeBool(offsets[1], object.hasSignature);
  writer.writeLong(offsets[2], object.height);
  writer.writeLong(offsets[3], object.order);
  writer.writeString(offsets[4], object.pageId);
  writer.writeString(offsets[5], object.processedImagePath);
  writer.writeString(offsets[6], object.rawImagePath);
  writer.writeString(offsets[7], object.signatureImagePath);
  writer.writeDouble(offsets[8], object.signatureScale);
  writer.writeDouble(offsets[9], object.signatureX);
  writer.writeDouble(offsets[10], object.signatureY);
  writer.writeDateTime(offsets[11], object.updatedAt);
  writer.writeLong(offsets[12], object.width);
}

PageEntity _pageEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PageEntity();
  object.documentId = reader.readString(offsets[0]);
  object.hasSignature = reader.readBool(offsets[1]);
  object.height = reader.readLong(offsets[2]);
  object.id = id;
  object.order = reader.readLong(offsets[3]);
  object.pageId = reader.readString(offsets[4]);
  object.processedImagePath = reader.readString(offsets[5]);
  object.rawImagePath = reader.readString(offsets[6]);
  object.signatureImagePath = reader.readStringOrNull(offsets[7]);
  object.signatureScale = reader.readDoubleOrNull(offsets[8]);
  object.signatureX = reader.readDoubleOrNull(offsets[9]);
  object.signatureY = reader.readDoubleOrNull(offsets[10]);
  object.updatedAt = reader.readDateTime(offsets[11]);
  object.width = reader.readLong(offsets[12]);
  return object;
}

P _pageEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pageEntityGetId(PageEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pageEntityGetLinks(PageEntity object) {
  return [object.ocrBlocks];
}

void _pageEntityAttach(IsarCollection<dynamic> col, Id id, PageEntity object) {
  object.id = id;
  object.ocrBlocks
      .attach(col, col.isar.collection<OcrBlockEntity>(), r'ocrBlocks', id);
}

extension PageEntityByIndex on IsarCollection<PageEntity> {
  Future<PageEntity?> getByPageId(String pageId) {
    return getByIndex(r'pageId', [pageId]);
  }

  PageEntity? getByPageIdSync(String pageId) {
    return getByIndexSync(r'pageId', [pageId]);
  }

  Future<bool> deleteByPageId(String pageId) {
    return deleteByIndex(r'pageId', [pageId]);
  }

  bool deleteByPageIdSync(String pageId) {
    return deleteByIndexSync(r'pageId', [pageId]);
  }

  Future<List<PageEntity?>> getAllByPageId(List<String> pageIdValues) {
    final values = pageIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'pageId', values);
  }

  List<PageEntity?> getAllByPageIdSync(List<String> pageIdValues) {
    final values = pageIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'pageId', values);
  }

  Future<int> deleteAllByPageId(List<String> pageIdValues) {
    final values = pageIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'pageId', values);
  }

  int deleteAllByPageIdSync(List<String> pageIdValues) {
    final values = pageIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'pageId', values);
  }

  Future<Id> putByPageId(PageEntity object) {
    return putByIndex(r'pageId', object);
  }

  Id putByPageIdSync(PageEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'pageId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPageId(List<PageEntity> objects) {
    return putAllByIndex(r'pageId', objects);
  }

  List<Id> putAllByPageIdSync(List<PageEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'pageId', objects, saveLinks: saveLinks);
  }
}

extension PageEntityQueryWhereSort
    on QueryBuilder<PageEntity, PageEntity, QWhere> {
  QueryBuilder<PageEntity, PageEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PageEntityQueryWhere
    on QueryBuilder<PageEntity, PageEntity, QWhereClause> {
  QueryBuilder<PageEntity, PageEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PageEntity, PageEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<PageEntity, PageEntity, QAfterWhereClause> pageIdEqualTo(
      String pageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pageId',
        value: [pageId],
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterWhereClause> pageIdNotEqualTo(
      String pageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageId',
              lower: [],
              upper: [pageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageId',
              lower: [pageId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageId',
              lower: [pageId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pageId',
              lower: [],
              upper: [pageId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PageEntityQueryFilter
    on QueryBuilder<PageEntity, PageEntity, QFilterCondition> {
  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> documentIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      hasSignatureEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasSignature',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> heightEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> heightGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> heightLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> heightBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> orderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> pageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageId',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      pageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pageId',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processedImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'processedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'processedImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processedImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      processedImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'processedImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      rawImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signatureImagePath',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signatureImagePath',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signatureImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signatureImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signatureImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'signatureImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'signatureImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signatureImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signatureImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signatureImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureScaleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signatureScale',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureScaleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signatureScale',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureScaleEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureScale',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureScaleGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signatureScale',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureScaleLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signatureScale',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureScaleBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signatureScale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureXIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signatureX',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureXIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signatureX',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> signatureXEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureXGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signatureX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureXLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signatureX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> signatureXBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signatureX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureYIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signatureY',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureYIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signatureY',
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> signatureYEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureYGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signatureY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      signatureYLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signatureY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> signatureYBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signatureY',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
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

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> widthEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> widthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> widthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'width',
        value: value,
      ));
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> widthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'width',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PageEntityQueryObject
    on QueryBuilder<PageEntity, PageEntity, QFilterCondition> {}

extension PageEntityQueryLinks
    on QueryBuilder<PageEntity, PageEntity, QFilterCondition> {
  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition> ocrBlocks(
      FilterQuery<OcrBlockEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'ocrBlocks');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      ocrBlocksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'ocrBlocks', length, true, length, true);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      ocrBlocksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'ocrBlocks', 0, true, 0, true);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      ocrBlocksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'ocrBlocks', 0, false, 999999, true);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      ocrBlocksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'ocrBlocks', 0, true, length, include);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      ocrBlocksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'ocrBlocks', length, include, 999999, true);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterFilterCondition>
      ocrBlocksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'ocrBlocks', lower, includeLower, upper, includeUpper);
    });
  }
}

extension PageEntityQuerySortBy
    on QueryBuilder<PageEntity, PageEntity, QSortBy> {
  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByHasSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignature', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByHasSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignature', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByPageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByPageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      sortByProcessedImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      sortByProcessedImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByRawImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByRawImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      sortBySignatureImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      sortBySignatureImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortBySignatureScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureScale', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      sortBySignatureScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureScale', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortBySignatureX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureX', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortBySignatureXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureX', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortBySignatureY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureY', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortBySignatureYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureY', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> sortByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension PageEntityQuerySortThenBy
    on QueryBuilder<PageEntity, PageEntity, QSortThenBy> {
  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByHasSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignature', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByHasSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignature', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByPageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByPageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      thenByProcessedImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      thenByProcessedImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processedImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByRawImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByRawImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      thenBySignatureImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureImagePath', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      thenBySignatureImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureImagePath', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenBySignatureScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureScale', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy>
      thenBySignatureScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureScale', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenBySignatureX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureX', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenBySignatureXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureX', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenBySignatureY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureY', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenBySignatureYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureY', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QAfterSortBy> thenByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension PageEntityQueryWhereDistinct
    on QueryBuilder<PageEntity, PageEntity, QDistinct> {
  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByHasSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasSignature');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByPageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByProcessedImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processedImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByRawImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawImagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctBySignatureImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signatureImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctBySignatureScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signatureScale');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctBySignatureX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signatureX');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctBySignatureY() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signatureY');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<PageEntity, PageEntity, QDistinct> distinctByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'width');
    });
  }
}

extension PageEntityQueryProperty
    on QueryBuilder<PageEntity, PageEntity, QQueryProperty> {
  QueryBuilder<PageEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PageEntity, String, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<PageEntity, bool, QQueryOperations> hasSignatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasSignature');
    });
  }

  QueryBuilder<PageEntity, int, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<PageEntity, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<PageEntity, String, QQueryOperations> pageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageId');
    });
  }

  QueryBuilder<PageEntity, String, QQueryOperations>
      processedImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processedImagePath');
    });
  }

  QueryBuilder<PageEntity, String, QQueryOperations> rawImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawImagePath');
    });
  }

  QueryBuilder<PageEntity, String?, QQueryOperations>
      signatureImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signatureImagePath');
    });
  }

  QueryBuilder<PageEntity, double?, QQueryOperations> signatureScaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signatureScale');
    });
  }

  QueryBuilder<PageEntity, double?, QQueryOperations> signatureXProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signatureX');
    });
  }

  QueryBuilder<PageEntity, double?, QQueryOperations> signatureYProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signatureY');
    });
  }

  QueryBuilder<PageEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PageEntity, int, QQueryOperations> widthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'width');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOcrBlockEntityCollection on Isar {
  IsarCollection<OcrBlockEntity> get ocrBlockEntitys => this.collection();
}

const OcrBlockEntitySchema = CollectionSchema(
  name: r'OcrBlockEntity',
  id: 6349137111236405622,
  properties: {
    r'bottom': PropertySchema(
      id: 0,
      name: r'bottom',
      type: IsarType.double,
    ),
    r'languageCode': PropertySchema(
      id: 1,
      name: r'languageCode',
      type: IsarType.string,
    ),
    r'left': PropertySchema(
      id: 2,
      name: r'left',
      type: IsarType.double,
    ),
    r'pageId': PropertySchema(
      id: 3,
      name: r'pageId',
      type: IsarType.string,
    ),
    r'right': PropertySchema(
      id: 4,
      name: r'right',
      type: IsarType.double,
    ),
    r'text': PropertySchema(
      id: 5,
      name: r'text',
      type: IsarType.string,
    ),
    r'top': PropertySchema(
      id: 6,
      name: r'top',
      type: IsarType.double,
    )
  },
  estimateSize: _ocrBlockEntityEstimateSize,
  serialize: _ocrBlockEntitySerialize,
  deserialize: _ocrBlockEntityDeserialize,
  deserializeProp: _ocrBlockEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _ocrBlockEntityGetId,
  getLinks: _ocrBlockEntityGetLinks,
  attach: _ocrBlockEntityAttach,
  version: '3.1.0+1',
);

int _ocrBlockEntityEstimateSize(
  OcrBlockEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.languageCode.length * 3;
  bytesCount += 3 + object.pageId.length * 3;
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _ocrBlockEntitySerialize(
  OcrBlockEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bottom);
  writer.writeString(offsets[1], object.languageCode);
  writer.writeDouble(offsets[2], object.left);
  writer.writeString(offsets[3], object.pageId);
  writer.writeDouble(offsets[4], object.right);
  writer.writeString(offsets[5], object.text);
  writer.writeDouble(offsets[6], object.top);
}

OcrBlockEntity _ocrBlockEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OcrBlockEntity();
  object.bottom = reader.readDouble(offsets[0]);
  object.id = id;
  object.languageCode = reader.readString(offsets[1]);
  object.left = reader.readDouble(offsets[2]);
  object.pageId = reader.readString(offsets[3]);
  object.right = reader.readDouble(offsets[4]);
  object.text = reader.readString(offsets[5]);
  object.top = reader.readDouble(offsets[6]);
  return object;
}

P _ocrBlockEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ocrBlockEntityGetId(OcrBlockEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ocrBlockEntityGetLinks(OcrBlockEntity object) {
  return [];
}

void _ocrBlockEntityAttach(
    IsarCollection<dynamic> col, Id id, OcrBlockEntity object) {
  object.id = id;
}

extension OcrBlockEntityQueryWhereSort
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QWhere> {
  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OcrBlockEntityQueryWhere
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QWhereClause> {
  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterWhereClause> idBetween(
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
}

extension OcrBlockEntityQueryFilter
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QFilterCondition> {
  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      bottomEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bottom',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      bottomGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bottom',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      bottomLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bottom',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      bottomBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bottom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
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

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
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

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languageCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languageCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      languageCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      leftEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'left',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      leftGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'left',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      leftLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'left',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      leftBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'left',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pageId',
        value: '',
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      pageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pageId',
        value: '',
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      rightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'right',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      rightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'right',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      rightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'right',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      rightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'right',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      topEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'top',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      topGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'top',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      topLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'top',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterFilterCondition>
      topBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'top',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension OcrBlockEntityQueryObject
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QFilterCondition> {}

extension OcrBlockEntityQueryLinks
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QFilterCondition> {}

extension OcrBlockEntityQuerySortBy
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QSortBy> {
  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByBottom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bottom', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      sortByBottomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bottom', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      sortByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      sortByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'left', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByLeftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'left', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByPageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      sortByPageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'right', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByRightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'right', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'top', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> sortByTopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'top', Sort.desc);
    });
  }
}

extension OcrBlockEntityQuerySortThenBy
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QSortThenBy> {
  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByBottom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bottom', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      thenByBottomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bottom', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      thenByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      thenByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'left', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByLeftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'left', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByPageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy>
      thenByPageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageId', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'right', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByRightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'right', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'top', Sort.asc);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QAfterSortBy> thenByTopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'top', Sort.desc);
    });
  }
}

extension OcrBlockEntityQueryWhereDistinct
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct> {
  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct> distinctByBottom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bottom');
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct>
      distinctByLanguageCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languageCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct> distinctByLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'left');
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct> distinctByPageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct> distinctByRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'right');
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OcrBlockEntity, OcrBlockEntity, QDistinct> distinctByTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'top');
    });
  }
}

extension OcrBlockEntityQueryProperty
    on QueryBuilder<OcrBlockEntity, OcrBlockEntity, QQueryProperty> {
  QueryBuilder<OcrBlockEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OcrBlockEntity, double, QQueryOperations> bottomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bottom');
    });
  }

  QueryBuilder<OcrBlockEntity, String, QQueryOperations>
      languageCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languageCode');
    });
  }

  QueryBuilder<OcrBlockEntity, double, QQueryOperations> leftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'left');
    });
  }

  QueryBuilder<OcrBlockEntity, String, QQueryOperations> pageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageId');
    });
  }

  QueryBuilder<OcrBlockEntity, double, QQueryOperations> rightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'right');
    });
  }

  QueryBuilder<OcrBlockEntity, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<OcrBlockEntity, double, QQueryOperations> topProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'top');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTagEntityCollection on Isar {
  IsarCollection<TagEntity> get tagEntitys => this.collection();
}

const TagEntitySchema = CollectionSchema(
  name: r'TagEntity',
  id: -1285872882773628843,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _tagEntityEstimateSize,
  serialize: _tagEntitySerialize,
  deserialize: _tagEntityDeserialize,
  deserializeProp: _tagEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _tagEntityGetId,
  getLinks: _tagEntityGetLinks,
  attach: _tagEntityAttach,
  version: '3.1.0+1',
);

int _tagEntityEstimateSize(
  TagEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _tagEntitySerialize(
  TagEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
}

TagEntity _tagEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TagEntity();
  object.id = id;
  object.name = reader.readString(offsets[0]);
  return object;
}

P _tagEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tagEntityGetId(TagEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tagEntityGetLinks(TagEntity object) {
  return [];
}

void _tagEntityAttach(IsarCollection<dynamic> col, Id id, TagEntity object) {
  object.id = id;
}

extension TagEntityByIndex on IsarCollection<TagEntity> {
  Future<TagEntity?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  TagEntity? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<TagEntity?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<TagEntity?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(TagEntity object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(TagEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<TagEntity> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<TagEntity> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension TagEntityQueryWhereSort
    on QueryBuilder<TagEntity, TagEntity, QWhere> {
  QueryBuilder<TagEntity, TagEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TagEntityQueryWhere
    on QueryBuilder<TagEntity, TagEntity, QWhereClause> {
  QueryBuilder<TagEntity, TagEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TagEntity, TagEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<TagEntity, TagEntity, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TagEntityQueryFilter
    on QueryBuilder<TagEntity, TagEntity, QFilterCondition> {
  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension TagEntityQueryObject
    on QueryBuilder<TagEntity, TagEntity, QFilterCondition> {}

extension TagEntityQueryLinks
    on QueryBuilder<TagEntity, TagEntity, QFilterCondition> {}

extension TagEntityQuerySortBy on QueryBuilder<TagEntity, TagEntity, QSortBy> {
  QueryBuilder<TagEntity, TagEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension TagEntityQuerySortThenBy
    on QueryBuilder<TagEntity, TagEntity, QSortThenBy> {
  QueryBuilder<TagEntity, TagEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TagEntity, TagEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension TagEntityQueryWhereDistinct
    on QueryBuilder<TagEntity, TagEntity, QDistinct> {
  QueryBuilder<TagEntity, TagEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension TagEntityQueryProperty
    on QueryBuilder<TagEntity, TagEntity, QQueryProperty> {
  QueryBuilder<TagEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TagEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
