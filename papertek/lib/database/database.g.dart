// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ShowMetaTable extends ShowMeta
    with TableInfo<$ShowMetaTable, ShowMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShowMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _showNameMeta = const VerificationMeta(
    'showName',
  );
  @override
  late final GeneratedColumn<String> showName = GeneratedColumn<String>(
    'show_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _producerMeta = const VerificationMeta(
    'producer',
  );
  @override
  late final GeneratedColumn<String> producer = GeneratedColumn<String>(
    'producer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _designerMeta = const VerificationMeta(
    'designer',
  );
  @override
  late final GeneratedColumn<String> designer = GeneratedColumn<String>(
    'designer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _designerUserIdMeta = const VerificationMeta(
    'designerUserId',
  );
  @override
  late final GeneratedColumn<String> designerUserId = GeneratedColumn<String>(
    'designer_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _asstDesignerMeta = const VerificationMeta(
    'asstDesigner',
  );
  @override
  late final GeneratedColumn<String> asstDesigner = GeneratedColumn<String>(
    'asst_designer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _designBusinessMeta = const VerificationMeta(
    'designBusiness',
  );
  @override
  late final GeneratedColumn<String> designBusiness = GeneratedColumn<String>(
    'design_business',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _masterElectricianMeta = const VerificationMeta(
    'masterElectrician',
  );
  @override
  late final GeneratedColumn<String> masterElectrician =
      GeneratedColumn<String>(
        'master_electrician',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _masterElectricianUserIdMeta =
      const VerificationMeta('masterElectricianUserId');
  @override
  late final GeneratedColumn<String> masterElectricianUserId =
      GeneratedColumn<String>(
        'master_electrician_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _asstMasterElectricianMeta =
      const VerificationMeta('asstMasterElectrician');
  @override
  late final GeneratedColumn<String> asstMasterElectrician =
      GeneratedColumn<String>(
        'asst_master_electrician',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _asstMasterElectricianUserIdMeta =
      const VerificationMeta('asstMasterElectricianUserId');
  @override
  late final GeneratedColumn<String> asstMasterElectricianUserId =
      GeneratedColumn<String>(
        'asst_master_electrician_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stageManagerMeta = const VerificationMeta(
    'stageManager',
  );
  @override
  late final GeneratedColumn<String> stageManager = GeneratedColumn<String>(
    'stage_manager',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
    'venue',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _techDateMeta = const VerificationMeta(
    'techDate',
  );
  @override
  late final GeneratedColumn<String> techDate = GeneratedColumn<String>(
    'tech_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingDateMeta = const VerificationMeta(
    'openingDate',
  );
  @override
  late final GeneratedColumn<String> openingDate = GeneratedColumn<String>(
    'opening_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closingDateMeta = const VerificationMeta(
    'closingDate',
  );
  @override
  late final GeneratedColumn<String> closingDate = GeneratedColumn<String>(
    'closing_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelDesignerMeta = const VerificationMeta(
    'labelDesigner',
  );
  @override
  late final GeneratedColumn<String> labelDesigner = GeneratedColumn<String>(
    'label_designer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelAsstDesignerMeta = const VerificationMeta(
    'labelAsstDesigner',
  );
  @override
  late final GeneratedColumn<String> labelAsstDesigner =
      GeneratedColumn<String>(
        'label_asst_designer',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _labelMasterElectricianMeta =
      const VerificationMeta('labelMasterElectrician');
  @override
  late final GeneratedColumn<String> labelMasterElectrician =
      GeneratedColumn<String>(
        'label_master_electrician',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _labelProducerMeta = const VerificationMeta(
    'labelProducer',
  );
  @override
  late final GeneratedColumn<String> labelProducer = GeneratedColumn<String>(
    'label_producer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelAsstMasterElectricianMeta =
      const VerificationMeta('labelAsstMasterElectrician');
  @override
  late final GeneratedColumn<String> labelAsstMasterElectrician =
      GeneratedColumn<String>(
        'label_asst_master_electrician',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _labelStageManagerMeta = const VerificationMeta(
    'labelStageManager',
  );
  @override
  late final GeneratedColumn<String> labelStageManager =
      GeneratedColumn<String>(
        'label_stage_manager',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    showName,
    company,
    orgId,
    producer,
    designer,
    designerUserId,
    asstDesigner,
    designBusiness,
    masterElectrician,
    masterElectricianUserId,
    asstMasterElectrician,
    asstMasterElectricianUserId,
    stageManager,
    venue,
    techDate,
    openingDate,
    closingDate,
    mode,
    cloudId,
    schemaVersion,
    labelDesigner,
    labelAsstDesigner,
    labelMasterElectrician,
    labelProducer,
    labelAsstMasterElectrician,
    labelStageManager,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'show_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShowMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('show_name')) {
      context.handle(
        _showNameMeta,
        showName.isAcceptableOrUnknown(data['show_name']!, _showNameMeta),
      );
    } else if (isInserting) {
      context.missing(_showNameMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    }
    if (data.containsKey('producer')) {
      context.handle(
        _producerMeta,
        producer.isAcceptableOrUnknown(data['producer']!, _producerMeta),
      );
    } else if (isInserting) {
      context.missing(_producerMeta);
    }
    if (data.containsKey('designer')) {
      context.handle(
        _designerMeta,
        designer.isAcceptableOrUnknown(data['designer']!, _designerMeta),
      );
    }
    if (data.containsKey('designer_user_id')) {
      context.handle(
        _designerUserIdMeta,
        designerUserId.isAcceptableOrUnknown(
          data['designer_user_id']!,
          _designerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('asst_designer')) {
      context.handle(
        _asstDesignerMeta,
        asstDesigner.isAcceptableOrUnknown(
          data['asst_designer']!,
          _asstDesignerMeta,
        ),
      );
    }
    if (data.containsKey('design_business')) {
      context.handle(
        _designBusinessMeta,
        designBusiness.isAcceptableOrUnknown(
          data['design_business']!,
          _designBusinessMeta,
        ),
      );
    }
    if (data.containsKey('master_electrician')) {
      context.handle(
        _masterElectricianMeta,
        masterElectrician.isAcceptableOrUnknown(
          data['master_electrician']!,
          _masterElectricianMeta,
        ),
      );
    }
    if (data.containsKey('master_electrician_user_id')) {
      context.handle(
        _masterElectricianUserIdMeta,
        masterElectricianUserId.isAcceptableOrUnknown(
          data['master_electrician_user_id']!,
          _masterElectricianUserIdMeta,
        ),
      );
    }
    if (data.containsKey('asst_master_electrician')) {
      context.handle(
        _asstMasterElectricianMeta,
        asstMasterElectrician.isAcceptableOrUnknown(
          data['asst_master_electrician']!,
          _asstMasterElectricianMeta,
        ),
      );
    }
    if (data.containsKey('asst_master_electrician_user_id')) {
      context.handle(
        _asstMasterElectricianUserIdMeta,
        asstMasterElectricianUserId.isAcceptableOrUnknown(
          data['asst_master_electrician_user_id']!,
          _asstMasterElectricianUserIdMeta,
        ),
      );
    }
    if (data.containsKey('stage_manager')) {
      context.handle(
        _stageManagerMeta,
        stageManager.isAcceptableOrUnknown(
          data['stage_manager']!,
          _stageManagerMeta,
        ),
      );
    }
    if (data.containsKey('venue')) {
      context.handle(
        _venueMeta,
        venue.isAcceptableOrUnknown(data['venue']!, _venueMeta),
      );
    }
    if (data.containsKey('tech_date')) {
      context.handle(
        _techDateMeta,
        techDate.isAcceptableOrUnknown(data['tech_date']!, _techDateMeta),
      );
    }
    if (data.containsKey('opening_date')) {
      context.handle(
        _openingDateMeta,
        openingDate.isAcceptableOrUnknown(
          data['opening_date']!,
          _openingDateMeta,
        ),
      );
    }
    if (data.containsKey('closing_date')) {
      context.handle(
        _closingDateMeta,
        closingDate.isAcceptableOrUnknown(
          data['closing_date']!,
          _closingDateMeta,
        ),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('label_designer')) {
      context.handle(
        _labelDesignerMeta,
        labelDesigner.isAcceptableOrUnknown(
          data['label_designer']!,
          _labelDesignerMeta,
        ),
      );
    }
    if (data.containsKey('label_asst_designer')) {
      context.handle(
        _labelAsstDesignerMeta,
        labelAsstDesigner.isAcceptableOrUnknown(
          data['label_asst_designer']!,
          _labelAsstDesignerMeta,
        ),
      );
    }
    if (data.containsKey('label_master_electrician')) {
      context.handle(
        _labelMasterElectricianMeta,
        labelMasterElectrician.isAcceptableOrUnknown(
          data['label_master_electrician']!,
          _labelMasterElectricianMeta,
        ),
      );
    }
    if (data.containsKey('label_producer')) {
      context.handle(
        _labelProducerMeta,
        labelProducer.isAcceptableOrUnknown(
          data['label_producer']!,
          _labelProducerMeta,
        ),
      );
    }
    if (data.containsKey('label_asst_master_electrician')) {
      context.handle(
        _labelAsstMasterElectricianMeta,
        labelAsstMasterElectrician.isAcceptableOrUnknown(
          data['label_asst_master_electrician']!,
          _labelAsstMasterElectricianMeta,
        ),
      );
    }
    if (data.containsKey('label_stage_manager')) {
      context.handle(
        _labelStageManagerMeta,
        labelStageManager.isAcceptableOrUnknown(
          data['label_stage_manager']!,
          _labelStageManagerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShowMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShowMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      showName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}show_name'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      ),
      producer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producer'],
      )!,
      designer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designer'],
      ),
      designerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designer_user_id'],
      ),
      asstDesigner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asst_designer'],
      ),
      designBusiness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}design_business'],
      ),
      masterElectrician: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}master_electrician'],
      ),
      masterElectricianUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}master_electrician_user_id'],
      ),
      asstMasterElectrician: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asst_master_electrician'],
      ),
      asstMasterElectricianUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asst_master_electrician_user_id'],
      ),
      stageManager: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_manager'],
      ),
      venue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venue'],
      ),
      techDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tech_date'],
      ),
      openingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_date'],
      ),
      closingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closing_date'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      ),
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      labelDesigner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_designer'],
      ),
      labelAsstDesigner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_asst_designer'],
      ),
      labelMasterElectrician: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_master_electrician'],
      ),
      labelProducer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_producer'],
      ),
      labelAsstMasterElectrician: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_asst_master_electrician'],
      ),
      labelStageManager: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_stage_manager'],
      ),
    );
  }

  @override
  $ShowMetaTable createAlias(String alias) {
    return $ShowMetaTable(attachedDatabase, alias);
  }
}

class ShowMetaData extends DataClass implements Insertable<ShowMetaData> {
  final int id;
  final String showName;
  final String? company;
  final String? orgId;
  final String producer;
  final String? designer;
  final String? designerUserId;
  final String? asstDesigner;
  final String? designBusiness;
  final String? masterElectrician;
  final String? masterElectricianUserId;
  final String? asstMasterElectrician;
  final String? asstMasterElectricianUserId;
  final String? stageManager;
  final String? venue;
  final String? techDate;
  final String? openingDate;
  final String? closingDate;
  final String? mode;
  final String? cloudId;
  final int schemaVersion;
  final String? labelDesigner;
  final String? labelAsstDesigner;
  final String? labelMasterElectrician;
  final String? labelProducer;
  final String? labelAsstMasterElectrician;
  final String? labelStageManager;
  const ShowMetaData({
    required this.id,
    required this.showName,
    this.company,
    this.orgId,
    required this.producer,
    this.designer,
    this.designerUserId,
    this.asstDesigner,
    this.designBusiness,
    this.masterElectrician,
    this.masterElectricianUserId,
    this.asstMasterElectrician,
    this.asstMasterElectricianUserId,
    this.stageManager,
    this.venue,
    this.techDate,
    this.openingDate,
    this.closingDate,
    this.mode,
    this.cloudId,
    required this.schemaVersion,
    this.labelDesigner,
    this.labelAsstDesigner,
    this.labelMasterElectrician,
    this.labelProducer,
    this.labelAsstMasterElectrician,
    this.labelStageManager,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['show_name'] = Variable<String>(showName);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || orgId != null) {
      map['org_id'] = Variable<String>(orgId);
    }
    map['producer'] = Variable<String>(producer);
    if (!nullToAbsent || designer != null) {
      map['designer'] = Variable<String>(designer);
    }
    if (!nullToAbsent || designerUserId != null) {
      map['designer_user_id'] = Variable<String>(designerUserId);
    }
    if (!nullToAbsent || asstDesigner != null) {
      map['asst_designer'] = Variable<String>(asstDesigner);
    }
    if (!nullToAbsent || designBusiness != null) {
      map['design_business'] = Variable<String>(designBusiness);
    }
    if (!nullToAbsent || masterElectrician != null) {
      map['master_electrician'] = Variable<String>(masterElectrician);
    }
    if (!nullToAbsent || masterElectricianUserId != null) {
      map['master_electrician_user_id'] = Variable<String>(
        masterElectricianUserId,
      );
    }
    if (!nullToAbsent || asstMasterElectrician != null) {
      map['asst_master_electrician'] = Variable<String>(asstMasterElectrician);
    }
    if (!nullToAbsent || asstMasterElectricianUserId != null) {
      map['asst_master_electrician_user_id'] = Variable<String>(
        asstMasterElectricianUserId,
      );
    }
    if (!nullToAbsent || stageManager != null) {
      map['stage_manager'] = Variable<String>(stageManager);
    }
    if (!nullToAbsent || venue != null) {
      map['venue'] = Variable<String>(venue);
    }
    if (!nullToAbsent || techDate != null) {
      map['tech_date'] = Variable<String>(techDate);
    }
    if (!nullToAbsent || openingDate != null) {
      map['opening_date'] = Variable<String>(openingDate);
    }
    if (!nullToAbsent || closingDate != null) {
      map['closing_date'] = Variable<String>(closingDate);
    }
    if (!nullToAbsent || mode != null) {
      map['mode'] = Variable<String>(mode);
    }
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    map['schema_version'] = Variable<int>(schemaVersion);
    if (!nullToAbsent || labelDesigner != null) {
      map['label_designer'] = Variable<String>(labelDesigner);
    }
    if (!nullToAbsent || labelAsstDesigner != null) {
      map['label_asst_designer'] = Variable<String>(labelAsstDesigner);
    }
    if (!nullToAbsent || labelMasterElectrician != null) {
      map['label_master_electrician'] = Variable<String>(
        labelMasterElectrician,
      );
    }
    if (!nullToAbsent || labelProducer != null) {
      map['label_producer'] = Variable<String>(labelProducer);
    }
    if (!nullToAbsent || labelAsstMasterElectrician != null) {
      map['label_asst_master_electrician'] = Variable<String>(
        labelAsstMasterElectrician,
      );
    }
    if (!nullToAbsent || labelStageManager != null) {
      map['label_stage_manager'] = Variable<String>(labelStageManager);
    }
    return map;
  }

  ShowMetaCompanion toCompanion(bool nullToAbsent) {
    return ShowMetaCompanion(
      id: Value(id),
      showName: Value(showName),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      orgId: orgId == null && nullToAbsent
          ? const Value.absent()
          : Value(orgId),
      producer: Value(producer),
      designer: designer == null && nullToAbsent
          ? const Value.absent()
          : Value(designer),
      designerUserId: designerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(designerUserId),
      asstDesigner: asstDesigner == null && nullToAbsent
          ? const Value.absent()
          : Value(asstDesigner),
      designBusiness: designBusiness == null && nullToAbsent
          ? const Value.absent()
          : Value(designBusiness),
      masterElectrician: masterElectrician == null && nullToAbsent
          ? const Value.absent()
          : Value(masterElectrician),
      masterElectricianUserId: masterElectricianUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(masterElectricianUserId),
      asstMasterElectrician: asstMasterElectrician == null && nullToAbsent
          ? const Value.absent()
          : Value(asstMasterElectrician),
      asstMasterElectricianUserId:
          asstMasterElectricianUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(asstMasterElectricianUserId),
      stageManager: stageManager == null && nullToAbsent
          ? const Value.absent()
          : Value(stageManager),
      venue: venue == null && nullToAbsent
          ? const Value.absent()
          : Value(venue),
      techDate: techDate == null && nullToAbsent
          ? const Value.absent()
          : Value(techDate),
      openingDate: openingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(openingDate),
      closingDate: closingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(closingDate),
      mode: mode == null && nullToAbsent ? const Value.absent() : Value(mode),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      schemaVersion: Value(schemaVersion),
      labelDesigner: labelDesigner == null && nullToAbsent
          ? const Value.absent()
          : Value(labelDesigner),
      labelAsstDesigner: labelAsstDesigner == null && nullToAbsent
          ? const Value.absent()
          : Value(labelAsstDesigner),
      labelMasterElectrician: labelMasterElectrician == null && nullToAbsent
          ? const Value.absent()
          : Value(labelMasterElectrician),
      labelProducer: labelProducer == null && nullToAbsent
          ? const Value.absent()
          : Value(labelProducer),
      labelAsstMasterElectrician:
          labelAsstMasterElectrician == null && nullToAbsent
          ? const Value.absent()
          : Value(labelAsstMasterElectrician),
      labelStageManager: labelStageManager == null && nullToAbsent
          ? const Value.absent()
          : Value(labelStageManager),
    );
  }

  factory ShowMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShowMetaData(
      id: serializer.fromJson<int>(json['id']),
      showName: serializer.fromJson<String>(json['showName']),
      company: serializer.fromJson<String?>(json['company']),
      orgId: serializer.fromJson<String?>(json['orgId']),
      producer: serializer.fromJson<String>(json['producer']),
      designer: serializer.fromJson<String?>(json['designer']),
      designerUserId: serializer.fromJson<String?>(json['designerUserId']),
      asstDesigner: serializer.fromJson<String?>(json['asstDesigner']),
      designBusiness: serializer.fromJson<String?>(json['designBusiness']),
      masterElectrician: serializer.fromJson<String?>(
        json['masterElectrician'],
      ),
      masterElectricianUserId: serializer.fromJson<String?>(
        json['masterElectricianUserId'],
      ),
      asstMasterElectrician: serializer.fromJson<String?>(
        json['asstMasterElectrician'],
      ),
      asstMasterElectricianUserId: serializer.fromJson<String?>(
        json['asstMasterElectricianUserId'],
      ),
      stageManager: serializer.fromJson<String?>(json['stageManager']),
      venue: serializer.fromJson<String?>(json['venue']),
      techDate: serializer.fromJson<String?>(json['techDate']),
      openingDate: serializer.fromJson<String?>(json['openingDate']),
      closingDate: serializer.fromJson<String?>(json['closingDate']),
      mode: serializer.fromJson<String?>(json['mode']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      labelDesigner: serializer.fromJson<String?>(json['labelDesigner']),
      labelAsstDesigner: serializer.fromJson<String?>(
        json['labelAsstDesigner'],
      ),
      labelMasterElectrician: serializer.fromJson<String?>(
        json['labelMasterElectrician'],
      ),
      labelProducer: serializer.fromJson<String?>(json['labelProducer']),
      labelAsstMasterElectrician: serializer.fromJson<String?>(
        json['labelAsstMasterElectrician'],
      ),
      labelStageManager: serializer.fromJson<String?>(
        json['labelStageManager'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'showName': serializer.toJson<String>(showName),
      'company': serializer.toJson<String?>(company),
      'orgId': serializer.toJson<String?>(orgId),
      'producer': serializer.toJson<String>(producer),
      'designer': serializer.toJson<String?>(designer),
      'designerUserId': serializer.toJson<String?>(designerUserId),
      'asstDesigner': serializer.toJson<String?>(asstDesigner),
      'designBusiness': serializer.toJson<String?>(designBusiness),
      'masterElectrician': serializer.toJson<String?>(masterElectrician),
      'masterElectricianUserId': serializer.toJson<String?>(
        masterElectricianUserId,
      ),
      'asstMasterElectrician': serializer.toJson<String?>(
        asstMasterElectrician,
      ),
      'asstMasterElectricianUserId': serializer.toJson<String?>(
        asstMasterElectricianUserId,
      ),
      'stageManager': serializer.toJson<String?>(stageManager),
      'venue': serializer.toJson<String?>(venue),
      'techDate': serializer.toJson<String?>(techDate),
      'openingDate': serializer.toJson<String?>(openingDate),
      'closingDate': serializer.toJson<String?>(closingDate),
      'mode': serializer.toJson<String?>(mode),
      'cloudId': serializer.toJson<String?>(cloudId),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'labelDesigner': serializer.toJson<String?>(labelDesigner),
      'labelAsstDesigner': serializer.toJson<String?>(labelAsstDesigner),
      'labelMasterElectrician': serializer.toJson<String?>(
        labelMasterElectrician,
      ),
      'labelProducer': serializer.toJson<String?>(labelProducer),
      'labelAsstMasterElectrician': serializer.toJson<String?>(
        labelAsstMasterElectrician,
      ),
      'labelStageManager': serializer.toJson<String?>(labelStageManager),
    };
  }

  ShowMetaData copyWith({
    int? id,
    String? showName,
    Value<String?> company = const Value.absent(),
    Value<String?> orgId = const Value.absent(),
    String? producer,
    Value<String?> designer = const Value.absent(),
    Value<String?> designerUserId = const Value.absent(),
    Value<String?> asstDesigner = const Value.absent(),
    Value<String?> designBusiness = const Value.absent(),
    Value<String?> masterElectrician = const Value.absent(),
    Value<String?> masterElectricianUserId = const Value.absent(),
    Value<String?> asstMasterElectrician = const Value.absent(),
    Value<String?> asstMasterElectricianUserId = const Value.absent(),
    Value<String?> stageManager = const Value.absent(),
    Value<String?> venue = const Value.absent(),
    Value<String?> techDate = const Value.absent(),
    Value<String?> openingDate = const Value.absent(),
    Value<String?> closingDate = const Value.absent(),
    Value<String?> mode = const Value.absent(),
    Value<String?> cloudId = const Value.absent(),
    int? schemaVersion,
    Value<String?> labelDesigner = const Value.absent(),
    Value<String?> labelAsstDesigner = const Value.absent(),
    Value<String?> labelMasterElectrician = const Value.absent(),
    Value<String?> labelProducer = const Value.absent(),
    Value<String?> labelAsstMasterElectrician = const Value.absent(),
    Value<String?> labelStageManager = const Value.absent(),
  }) => ShowMetaData(
    id: id ?? this.id,
    showName: showName ?? this.showName,
    company: company.present ? company.value : this.company,
    orgId: orgId.present ? orgId.value : this.orgId,
    producer: producer ?? this.producer,
    designer: designer.present ? designer.value : this.designer,
    designerUserId: designerUserId.present
        ? designerUserId.value
        : this.designerUserId,
    asstDesigner: asstDesigner.present ? asstDesigner.value : this.asstDesigner,
    designBusiness: designBusiness.present
        ? designBusiness.value
        : this.designBusiness,
    masterElectrician: masterElectrician.present
        ? masterElectrician.value
        : this.masterElectrician,
    masterElectricianUserId: masterElectricianUserId.present
        ? masterElectricianUserId.value
        : this.masterElectricianUserId,
    asstMasterElectrician: asstMasterElectrician.present
        ? asstMasterElectrician.value
        : this.asstMasterElectrician,
    asstMasterElectricianUserId: asstMasterElectricianUserId.present
        ? asstMasterElectricianUserId.value
        : this.asstMasterElectricianUserId,
    stageManager: stageManager.present ? stageManager.value : this.stageManager,
    venue: venue.present ? venue.value : this.venue,
    techDate: techDate.present ? techDate.value : this.techDate,
    openingDate: openingDate.present ? openingDate.value : this.openingDate,
    closingDate: closingDate.present ? closingDate.value : this.closingDate,
    mode: mode.present ? mode.value : this.mode,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    labelDesigner: labelDesigner.present
        ? labelDesigner.value
        : this.labelDesigner,
    labelAsstDesigner: labelAsstDesigner.present
        ? labelAsstDesigner.value
        : this.labelAsstDesigner,
    labelMasterElectrician: labelMasterElectrician.present
        ? labelMasterElectrician.value
        : this.labelMasterElectrician,
    labelProducer: labelProducer.present
        ? labelProducer.value
        : this.labelProducer,
    labelAsstMasterElectrician: labelAsstMasterElectrician.present
        ? labelAsstMasterElectrician.value
        : this.labelAsstMasterElectrician,
    labelStageManager: labelStageManager.present
        ? labelStageManager.value
        : this.labelStageManager,
  );
  ShowMetaData copyWithCompanion(ShowMetaCompanion data) {
    return ShowMetaData(
      id: data.id.present ? data.id.value : this.id,
      showName: data.showName.present ? data.showName.value : this.showName,
      company: data.company.present ? data.company.value : this.company,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      producer: data.producer.present ? data.producer.value : this.producer,
      designer: data.designer.present ? data.designer.value : this.designer,
      designerUserId: data.designerUserId.present
          ? data.designerUserId.value
          : this.designerUserId,
      asstDesigner: data.asstDesigner.present
          ? data.asstDesigner.value
          : this.asstDesigner,
      designBusiness: data.designBusiness.present
          ? data.designBusiness.value
          : this.designBusiness,
      masterElectrician: data.masterElectrician.present
          ? data.masterElectrician.value
          : this.masterElectrician,
      masterElectricianUserId: data.masterElectricianUserId.present
          ? data.masterElectricianUserId.value
          : this.masterElectricianUserId,
      asstMasterElectrician: data.asstMasterElectrician.present
          ? data.asstMasterElectrician.value
          : this.asstMasterElectrician,
      asstMasterElectricianUserId: data.asstMasterElectricianUserId.present
          ? data.asstMasterElectricianUserId.value
          : this.asstMasterElectricianUserId,
      stageManager: data.stageManager.present
          ? data.stageManager.value
          : this.stageManager,
      venue: data.venue.present ? data.venue.value : this.venue,
      techDate: data.techDate.present ? data.techDate.value : this.techDate,
      openingDate: data.openingDate.present
          ? data.openingDate.value
          : this.openingDate,
      closingDate: data.closingDate.present
          ? data.closingDate.value
          : this.closingDate,
      mode: data.mode.present ? data.mode.value : this.mode,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      labelDesigner: data.labelDesigner.present
          ? data.labelDesigner.value
          : this.labelDesigner,
      labelAsstDesigner: data.labelAsstDesigner.present
          ? data.labelAsstDesigner.value
          : this.labelAsstDesigner,
      labelMasterElectrician: data.labelMasterElectrician.present
          ? data.labelMasterElectrician.value
          : this.labelMasterElectrician,
      labelProducer: data.labelProducer.present
          ? data.labelProducer.value
          : this.labelProducer,
      labelAsstMasterElectrician: data.labelAsstMasterElectrician.present
          ? data.labelAsstMasterElectrician.value
          : this.labelAsstMasterElectrician,
      labelStageManager: data.labelStageManager.present
          ? data.labelStageManager.value
          : this.labelStageManager,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShowMetaData(')
          ..write('id: $id, ')
          ..write('showName: $showName, ')
          ..write('company: $company, ')
          ..write('orgId: $orgId, ')
          ..write('producer: $producer, ')
          ..write('designer: $designer, ')
          ..write('designerUserId: $designerUserId, ')
          ..write('asstDesigner: $asstDesigner, ')
          ..write('designBusiness: $designBusiness, ')
          ..write('masterElectrician: $masterElectrician, ')
          ..write('masterElectricianUserId: $masterElectricianUserId, ')
          ..write('asstMasterElectrician: $asstMasterElectrician, ')
          ..write('asstMasterElectricianUserId: $asstMasterElectricianUserId, ')
          ..write('stageManager: $stageManager, ')
          ..write('venue: $venue, ')
          ..write('techDate: $techDate, ')
          ..write('openingDate: $openingDate, ')
          ..write('closingDate: $closingDate, ')
          ..write('mode: $mode, ')
          ..write('cloudId: $cloudId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('labelDesigner: $labelDesigner, ')
          ..write('labelAsstDesigner: $labelAsstDesigner, ')
          ..write('labelMasterElectrician: $labelMasterElectrician, ')
          ..write('labelProducer: $labelProducer, ')
          ..write('labelAsstMasterElectrician: $labelAsstMasterElectrician, ')
          ..write('labelStageManager: $labelStageManager')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    showName,
    company,
    orgId,
    producer,
    designer,
    designerUserId,
    asstDesigner,
    designBusiness,
    masterElectrician,
    masterElectricianUserId,
    asstMasterElectrician,
    asstMasterElectricianUserId,
    stageManager,
    venue,
    techDate,
    openingDate,
    closingDate,
    mode,
    cloudId,
    schemaVersion,
    labelDesigner,
    labelAsstDesigner,
    labelMasterElectrician,
    labelProducer,
    labelAsstMasterElectrician,
    labelStageManager,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShowMetaData &&
          other.id == this.id &&
          other.showName == this.showName &&
          other.company == this.company &&
          other.orgId == this.orgId &&
          other.producer == this.producer &&
          other.designer == this.designer &&
          other.designerUserId == this.designerUserId &&
          other.asstDesigner == this.asstDesigner &&
          other.designBusiness == this.designBusiness &&
          other.masterElectrician == this.masterElectrician &&
          other.masterElectricianUserId == this.masterElectricianUserId &&
          other.asstMasterElectrician == this.asstMasterElectrician &&
          other.asstMasterElectricianUserId ==
              this.asstMasterElectricianUserId &&
          other.stageManager == this.stageManager &&
          other.venue == this.venue &&
          other.techDate == this.techDate &&
          other.openingDate == this.openingDate &&
          other.closingDate == this.closingDate &&
          other.mode == this.mode &&
          other.cloudId == this.cloudId &&
          other.schemaVersion == this.schemaVersion &&
          other.labelDesigner == this.labelDesigner &&
          other.labelAsstDesigner == this.labelAsstDesigner &&
          other.labelMasterElectrician == this.labelMasterElectrician &&
          other.labelProducer == this.labelProducer &&
          other.labelAsstMasterElectrician == this.labelAsstMasterElectrician &&
          other.labelStageManager == this.labelStageManager);
}

class ShowMetaCompanion extends UpdateCompanion<ShowMetaData> {
  final Value<int> id;
  final Value<String> showName;
  final Value<String?> company;
  final Value<String?> orgId;
  final Value<String> producer;
  final Value<String?> designer;
  final Value<String?> designerUserId;
  final Value<String?> asstDesigner;
  final Value<String?> designBusiness;
  final Value<String?> masterElectrician;
  final Value<String?> masterElectricianUserId;
  final Value<String?> asstMasterElectrician;
  final Value<String?> asstMasterElectricianUserId;
  final Value<String?> stageManager;
  final Value<String?> venue;
  final Value<String?> techDate;
  final Value<String?> openingDate;
  final Value<String?> closingDate;
  final Value<String?> mode;
  final Value<String?> cloudId;
  final Value<int> schemaVersion;
  final Value<String?> labelDesigner;
  final Value<String?> labelAsstDesigner;
  final Value<String?> labelMasterElectrician;
  final Value<String?> labelProducer;
  final Value<String?> labelAsstMasterElectrician;
  final Value<String?> labelStageManager;
  const ShowMetaCompanion({
    this.id = const Value.absent(),
    this.showName = const Value.absent(),
    this.company = const Value.absent(),
    this.orgId = const Value.absent(),
    this.producer = const Value.absent(),
    this.designer = const Value.absent(),
    this.designerUserId = const Value.absent(),
    this.asstDesigner = const Value.absent(),
    this.designBusiness = const Value.absent(),
    this.masterElectrician = const Value.absent(),
    this.masterElectricianUserId = const Value.absent(),
    this.asstMasterElectrician = const Value.absent(),
    this.asstMasterElectricianUserId = const Value.absent(),
    this.stageManager = const Value.absent(),
    this.venue = const Value.absent(),
    this.techDate = const Value.absent(),
    this.openingDate = const Value.absent(),
    this.closingDate = const Value.absent(),
    this.mode = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.labelDesigner = const Value.absent(),
    this.labelAsstDesigner = const Value.absent(),
    this.labelMasterElectrician = const Value.absent(),
    this.labelProducer = const Value.absent(),
    this.labelAsstMasterElectrician = const Value.absent(),
    this.labelStageManager = const Value.absent(),
  });
  ShowMetaCompanion.insert({
    this.id = const Value.absent(),
    required String showName,
    this.company = const Value.absent(),
    this.orgId = const Value.absent(),
    required String producer,
    this.designer = const Value.absent(),
    this.designerUserId = const Value.absent(),
    this.asstDesigner = const Value.absent(),
    this.designBusiness = const Value.absent(),
    this.masterElectrician = const Value.absent(),
    this.masterElectricianUserId = const Value.absent(),
    this.asstMasterElectrician = const Value.absent(),
    this.asstMasterElectricianUserId = const Value.absent(),
    this.stageManager = const Value.absent(),
    this.venue = const Value.absent(),
    this.techDate = const Value.absent(),
    this.openingDate = const Value.absent(),
    this.closingDate = const Value.absent(),
    this.mode = const Value.absent(),
    this.cloudId = const Value.absent(),
    required int schemaVersion,
    this.labelDesigner = const Value.absent(),
    this.labelAsstDesigner = const Value.absent(),
    this.labelMasterElectrician = const Value.absent(),
    this.labelProducer = const Value.absent(),
    this.labelAsstMasterElectrician = const Value.absent(),
    this.labelStageManager = const Value.absent(),
  }) : showName = Value(showName),
       producer = Value(producer),
       schemaVersion = Value(schemaVersion);
  static Insertable<ShowMetaData> custom({
    Expression<int>? id,
    Expression<String>? showName,
    Expression<String>? company,
    Expression<String>? orgId,
    Expression<String>? producer,
    Expression<String>? designer,
    Expression<String>? designerUserId,
    Expression<String>? asstDesigner,
    Expression<String>? designBusiness,
    Expression<String>? masterElectrician,
    Expression<String>? masterElectricianUserId,
    Expression<String>? asstMasterElectrician,
    Expression<String>? asstMasterElectricianUserId,
    Expression<String>? stageManager,
    Expression<String>? venue,
    Expression<String>? techDate,
    Expression<String>? openingDate,
    Expression<String>? closingDate,
    Expression<String>? mode,
    Expression<String>? cloudId,
    Expression<int>? schemaVersion,
    Expression<String>? labelDesigner,
    Expression<String>? labelAsstDesigner,
    Expression<String>? labelMasterElectrician,
    Expression<String>? labelProducer,
    Expression<String>? labelAsstMasterElectrician,
    Expression<String>? labelStageManager,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (showName != null) 'show_name': showName,
      if (company != null) 'company': company,
      if (orgId != null) 'org_id': orgId,
      if (producer != null) 'producer': producer,
      if (designer != null) 'designer': designer,
      if (designerUserId != null) 'designer_user_id': designerUserId,
      if (asstDesigner != null) 'asst_designer': asstDesigner,
      if (designBusiness != null) 'design_business': designBusiness,
      if (masterElectrician != null) 'master_electrician': masterElectrician,
      if (masterElectricianUserId != null)
        'master_electrician_user_id': masterElectricianUserId,
      if (asstMasterElectrician != null)
        'asst_master_electrician': asstMasterElectrician,
      if (asstMasterElectricianUserId != null)
        'asst_master_electrician_user_id': asstMasterElectricianUserId,
      if (stageManager != null) 'stage_manager': stageManager,
      if (venue != null) 'venue': venue,
      if (techDate != null) 'tech_date': techDate,
      if (openingDate != null) 'opening_date': openingDate,
      if (closingDate != null) 'closing_date': closingDate,
      if (mode != null) 'mode': mode,
      if (cloudId != null) 'cloud_id': cloudId,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (labelDesigner != null) 'label_designer': labelDesigner,
      if (labelAsstDesigner != null) 'label_asst_designer': labelAsstDesigner,
      if (labelMasterElectrician != null)
        'label_master_electrician': labelMasterElectrician,
      if (labelProducer != null) 'label_producer': labelProducer,
      if (labelAsstMasterElectrician != null)
        'label_asst_master_electrician': labelAsstMasterElectrician,
      if (labelStageManager != null) 'label_stage_manager': labelStageManager,
    });
  }

  ShowMetaCompanion copyWith({
    Value<int>? id,
    Value<String>? showName,
    Value<String?>? company,
    Value<String?>? orgId,
    Value<String>? producer,
    Value<String?>? designer,
    Value<String?>? designerUserId,
    Value<String?>? asstDesigner,
    Value<String?>? designBusiness,
    Value<String?>? masterElectrician,
    Value<String?>? masterElectricianUserId,
    Value<String?>? asstMasterElectrician,
    Value<String?>? asstMasterElectricianUserId,
    Value<String?>? stageManager,
    Value<String?>? venue,
    Value<String?>? techDate,
    Value<String?>? openingDate,
    Value<String?>? closingDate,
    Value<String?>? mode,
    Value<String?>? cloudId,
    Value<int>? schemaVersion,
    Value<String?>? labelDesigner,
    Value<String?>? labelAsstDesigner,
    Value<String?>? labelMasterElectrician,
    Value<String?>? labelProducer,
    Value<String?>? labelAsstMasterElectrician,
    Value<String?>? labelStageManager,
  }) {
    return ShowMetaCompanion(
      id: id ?? this.id,
      showName: showName ?? this.showName,
      company: company ?? this.company,
      orgId: orgId ?? this.orgId,
      producer: producer ?? this.producer,
      designer: designer ?? this.designer,
      designerUserId: designerUserId ?? this.designerUserId,
      asstDesigner: asstDesigner ?? this.asstDesigner,
      designBusiness: designBusiness ?? this.designBusiness,
      masterElectrician: masterElectrician ?? this.masterElectrician,
      masterElectricianUserId:
          masterElectricianUserId ?? this.masterElectricianUserId,
      asstMasterElectrician:
          asstMasterElectrician ?? this.asstMasterElectrician,
      asstMasterElectricianUserId:
          asstMasterElectricianUserId ?? this.asstMasterElectricianUserId,
      stageManager: stageManager ?? this.stageManager,
      venue: venue ?? this.venue,
      techDate: techDate ?? this.techDate,
      openingDate: openingDate ?? this.openingDate,
      closingDate: closingDate ?? this.closingDate,
      mode: mode ?? this.mode,
      cloudId: cloudId ?? this.cloudId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      labelDesigner: labelDesigner ?? this.labelDesigner,
      labelAsstDesigner: labelAsstDesigner ?? this.labelAsstDesigner,
      labelMasterElectrician:
          labelMasterElectrician ?? this.labelMasterElectrician,
      labelProducer: labelProducer ?? this.labelProducer,
      labelAsstMasterElectrician:
          labelAsstMasterElectrician ?? this.labelAsstMasterElectrician,
      labelStageManager: labelStageManager ?? this.labelStageManager,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (showName.present) {
      map['show_name'] = Variable<String>(showName.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (producer.present) {
      map['producer'] = Variable<String>(producer.value);
    }
    if (designer.present) {
      map['designer'] = Variable<String>(designer.value);
    }
    if (designerUserId.present) {
      map['designer_user_id'] = Variable<String>(designerUserId.value);
    }
    if (asstDesigner.present) {
      map['asst_designer'] = Variable<String>(asstDesigner.value);
    }
    if (designBusiness.present) {
      map['design_business'] = Variable<String>(designBusiness.value);
    }
    if (masterElectrician.present) {
      map['master_electrician'] = Variable<String>(masterElectrician.value);
    }
    if (masterElectricianUserId.present) {
      map['master_electrician_user_id'] = Variable<String>(
        masterElectricianUserId.value,
      );
    }
    if (asstMasterElectrician.present) {
      map['asst_master_electrician'] = Variable<String>(
        asstMasterElectrician.value,
      );
    }
    if (asstMasterElectricianUserId.present) {
      map['asst_master_electrician_user_id'] = Variable<String>(
        asstMasterElectricianUserId.value,
      );
    }
    if (stageManager.present) {
      map['stage_manager'] = Variable<String>(stageManager.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (techDate.present) {
      map['tech_date'] = Variable<String>(techDate.value);
    }
    if (openingDate.present) {
      map['opening_date'] = Variable<String>(openingDate.value);
    }
    if (closingDate.present) {
      map['closing_date'] = Variable<String>(closingDate.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (labelDesigner.present) {
      map['label_designer'] = Variable<String>(labelDesigner.value);
    }
    if (labelAsstDesigner.present) {
      map['label_asst_designer'] = Variable<String>(labelAsstDesigner.value);
    }
    if (labelMasterElectrician.present) {
      map['label_master_electrician'] = Variable<String>(
        labelMasterElectrician.value,
      );
    }
    if (labelProducer.present) {
      map['label_producer'] = Variable<String>(labelProducer.value);
    }
    if (labelAsstMasterElectrician.present) {
      map['label_asst_master_electrician'] = Variable<String>(
        labelAsstMasterElectrician.value,
      );
    }
    if (labelStageManager.present) {
      map['label_stage_manager'] = Variable<String>(labelStageManager.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShowMetaCompanion(')
          ..write('id: $id, ')
          ..write('showName: $showName, ')
          ..write('company: $company, ')
          ..write('orgId: $orgId, ')
          ..write('producer: $producer, ')
          ..write('designer: $designer, ')
          ..write('designerUserId: $designerUserId, ')
          ..write('asstDesigner: $asstDesigner, ')
          ..write('designBusiness: $designBusiness, ')
          ..write('masterElectrician: $masterElectrician, ')
          ..write('masterElectricianUserId: $masterElectricianUserId, ')
          ..write('asstMasterElectrician: $asstMasterElectrician, ')
          ..write('asstMasterElectricianUserId: $asstMasterElectricianUserId, ')
          ..write('stageManager: $stageManager, ')
          ..write('venue: $venue, ')
          ..write('techDate: $techDate, ')
          ..write('openingDate: $openingDate, ')
          ..write('closingDate: $closingDate, ')
          ..write('mode: $mode, ')
          ..write('cloudId: $cloudId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('labelDesigner: $labelDesigner, ')
          ..write('labelAsstDesigner: $labelAsstDesigner, ')
          ..write('labelMasterElectrician: $labelMasterElectrician, ')
          ..write('labelProducer: $labelProducer, ')
          ..write('labelAsstMasterElectrician: $labelAsstMasterElectrician, ')
          ..write('labelStageManager: $labelStageManager')
          ..write(')'))
        .toString();
  }
}

class $UsersLocalTable extends UsersLocal
    with TableInfo<$UsersLocalTable, UsersLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<String> lastSeen = GeneratedColumn<String>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    displayName,
    avatarUrl,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UsersLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersLocalData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen'],
      ),
    );
  }

  @override
  $UsersLocalTable createAlias(String alias) {
    return $UsersLocalTable(attachedDatabase, alias);
  }
}

class UsersLocalData extends DataClass implements Insertable<UsersLocalData> {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? lastSeen;
  const UsersLocalData({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<String>(lastSeen);
    }
    return map;
  }

  UsersLocalCompanion toCompanion(bool nullToAbsent) {
    return UsersLocalCompanion(
      userId: Value(userId),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
    );
  }

  factory UsersLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersLocalData(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      lastSeen: serializer.fromJson<String?>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'lastSeen': serializer.toJson<String?>(lastSeen),
    };
  }

  UsersLocalData copyWith({
    String? userId,
    String? displayName,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> lastSeen = const Value.absent(),
  }) => UsersLocalData(
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
  );
  UsersLocalData copyWithCompanion(UsersLocalCompanion data) {
    return UsersLocalData(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersLocalData(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, displayName, avatarUrl, lastSeen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersLocalData &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.lastSeen == this.lastSeen);
}

class UsersLocalCompanion extends UpdateCompanion<UsersLocalData> {
  final Value<String> userId;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<String?> lastSeen;
  final Value<int> rowid;
  const UsersLocalCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersLocalCompanion.insert({
    required String userId,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       displayName = Value(displayName);
  static Insertable<UsersLocalData> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<String>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersLocalCompanion copyWith({
    Value<String>? userId,
    Value<String>? displayName,
    Value<String?>? avatarUrl,
    Value<String?>? lastSeen,
    Value<int>? rowid,
  }) {
    return UsersLocalCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<String>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersLocalCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LightingPositionsTable extends LightingPositions
    with TableInfo<$LightingPositionsTable, LightingPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LightingPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _trimMeta = const VerificationMeta('trim');
  @override
  late final GeneratedColumn<String> trim = GeneratedColumn<String>(
    'trim',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromPlasterLineMeta = const VerificationMeta(
    'fromPlasterLine',
  );
  @override
  late final GeneratedColumn<String> fromPlasterLine = GeneratedColumn<String>(
    'from_plaster_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromCenterLineMeta = const VerificationMeta(
    'fromCenterLine',
  );
  @override
  late final GeneratedColumn<String> fromCenterLine = GeneratedColumn<String>(
    'from_center_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    trim,
    fromPlasterLine,
    fromCenterLine,
    sortOrder,
    groupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lighting_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LightingPosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('trim')) {
      context.handle(
        _trimMeta,
        trim.isAcceptableOrUnknown(data['trim']!, _trimMeta),
      );
    }
    if (data.containsKey('from_plaster_line')) {
      context.handle(
        _fromPlasterLineMeta,
        fromPlasterLine.isAcceptableOrUnknown(
          data['from_plaster_line']!,
          _fromPlasterLineMeta,
        ),
      );
    }
    if (data.containsKey('from_center_line')) {
      context.handle(
        _fromCenterLineMeta,
        fromCenterLine.isAcceptableOrUnknown(
          data['from_center_line']!,
          _fromCenterLineMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LightingPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LightingPosition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      trim: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trim'],
      ),
      fromPlasterLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_plaster_line'],
      ),
      fromCenterLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_center_line'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      ),
    );
  }

  @override
  $LightingPositionsTable createAlias(String alias) {
    return $LightingPositionsTable(attachedDatabase, alias);
  }
}

class LightingPosition extends DataClass
    implements Insertable<LightingPosition> {
  final int id;
  final String name;
  final String? trim;
  final String? fromPlasterLine;
  final String? fromCenterLine;
  final int sortOrder;
  final int? groupId;
  const LightingPosition({
    required this.id,
    required this.name,
    this.trim,
    this.fromPlasterLine,
    this.fromCenterLine,
    required this.sortOrder,
    this.groupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || trim != null) {
      map['trim'] = Variable<String>(trim);
    }
    if (!nullToAbsent || fromPlasterLine != null) {
      map['from_plaster_line'] = Variable<String>(fromPlasterLine);
    }
    if (!nullToAbsent || fromCenterLine != null) {
      map['from_center_line'] = Variable<String>(fromCenterLine);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<int>(groupId);
    }
    return map;
  }

  LightingPositionsCompanion toCompanion(bool nullToAbsent) {
    return LightingPositionsCompanion(
      id: Value(id),
      name: Value(name),
      trim: trim == null && nullToAbsent ? const Value.absent() : Value(trim),
      fromPlasterLine: fromPlasterLine == null && nullToAbsent
          ? const Value.absent()
          : Value(fromPlasterLine),
      fromCenterLine: fromCenterLine == null && nullToAbsent
          ? const Value.absent()
          : Value(fromCenterLine),
      sortOrder: Value(sortOrder),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
    );
  }

  factory LightingPosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LightingPosition(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      trim: serializer.fromJson<String?>(json['trim']),
      fromPlasterLine: serializer.fromJson<String?>(json['fromPlasterLine']),
      fromCenterLine: serializer.fromJson<String?>(json['fromCenterLine']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      groupId: serializer.fromJson<int?>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'trim': serializer.toJson<String?>(trim),
      'fromPlasterLine': serializer.toJson<String?>(fromPlasterLine),
      'fromCenterLine': serializer.toJson<String?>(fromCenterLine),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'groupId': serializer.toJson<int?>(groupId),
    };
  }

  LightingPosition copyWith({
    int? id,
    String? name,
    Value<String?> trim = const Value.absent(),
    Value<String?> fromPlasterLine = const Value.absent(),
    Value<String?> fromCenterLine = const Value.absent(),
    int? sortOrder,
    Value<int?> groupId = const Value.absent(),
  }) => LightingPosition(
    id: id ?? this.id,
    name: name ?? this.name,
    trim: trim.present ? trim.value : this.trim,
    fromPlasterLine: fromPlasterLine.present
        ? fromPlasterLine.value
        : this.fromPlasterLine,
    fromCenterLine: fromCenterLine.present
        ? fromCenterLine.value
        : this.fromCenterLine,
    sortOrder: sortOrder ?? this.sortOrder,
    groupId: groupId.present ? groupId.value : this.groupId,
  );
  LightingPosition copyWithCompanion(LightingPositionsCompanion data) {
    return LightingPosition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      trim: data.trim.present ? data.trim.value : this.trim,
      fromPlasterLine: data.fromPlasterLine.present
          ? data.fromPlasterLine.value
          : this.fromPlasterLine,
      fromCenterLine: data.fromCenterLine.present
          ? data.fromCenterLine.value
          : this.fromCenterLine,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LightingPosition(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trim: $trim, ')
          ..write('fromPlasterLine: $fromPlasterLine, ')
          ..write('fromCenterLine: $fromCenterLine, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    trim,
    fromPlasterLine,
    fromCenterLine,
    sortOrder,
    groupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LightingPosition &&
          other.id == this.id &&
          other.name == this.name &&
          other.trim == this.trim &&
          other.fromPlasterLine == this.fromPlasterLine &&
          other.fromCenterLine == this.fromCenterLine &&
          other.sortOrder == this.sortOrder &&
          other.groupId == this.groupId);
}

class LightingPositionsCompanion extends UpdateCompanion<LightingPosition> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> trim;
  final Value<String?> fromPlasterLine;
  final Value<String?> fromCenterLine;
  final Value<int> sortOrder;
  final Value<int?> groupId;
  const LightingPositionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.trim = const Value.absent(),
    this.fromPlasterLine = const Value.absent(),
    this.fromCenterLine = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.groupId = const Value.absent(),
  });
  LightingPositionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.trim = const Value.absent(),
    this.fromPlasterLine = const Value.absent(),
    this.fromCenterLine = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.groupId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<LightingPosition> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? trim,
    Expression<String>? fromPlasterLine,
    Expression<String>? fromCenterLine,
    Expression<int>? sortOrder,
    Expression<int>? groupId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (trim != null) 'trim': trim,
      if (fromPlasterLine != null) 'from_plaster_line': fromPlasterLine,
      if (fromCenterLine != null) 'from_center_line': fromCenterLine,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (groupId != null) 'group_id': groupId,
    });
  }

  LightingPositionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? trim,
    Value<String?>? fromPlasterLine,
    Value<String?>? fromCenterLine,
    Value<int>? sortOrder,
    Value<int?>? groupId,
  }) {
    return LightingPositionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      trim: trim ?? this.trim,
      fromPlasterLine: fromPlasterLine ?? this.fromPlasterLine,
      fromCenterLine: fromCenterLine ?? this.fromCenterLine,
      sortOrder: sortOrder ?? this.sortOrder,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (trim.present) {
      map['trim'] = Variable<String>(trim.value);
    }
    if (fromPlasterLine.present) {
      map['from_plaster_line'] = Variable<String>(fromPlasterLine.value);
    }
    if (fromCenterLine.present) {
      map['from_center_line'] = Variable<String>(fromCenterLine.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LightingPositionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trim: $trim, ')
          ..write('fromPlasterLine: $fromPlasterLine, ')
          ..write('fromCenterLine: $fromCenterLine, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }
}

class $CircuitsTable extends Circuits with TableInfo<$CircuitsTable, Circuit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CircuitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dimmerMeta = const VerificationMeta('dimmer');
  @override
  late final GeneratedColumn<String> dimmer = GeneratedColumn<String>(
    'dimmer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<String> capacity = GeneratedColumn<String>(
    'capacity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, dimmer, capacity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circuits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Circuit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dimmer')) {
      context.handle(
        _dimmerMeta,
        dimmer.isAcceptableOrUnknown(data['dimmer']!, _dimmerMeta),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Circuit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Circuit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dimmer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimmer'],
      ),
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capacity'],
      ),
    );
  }

  @override
  $CircuitsTable createAlias(String alias) {
    return $CircuitsTable(attachedDatabase, alias);
  }
}

class Circuit extends DataClass implements Insertable<Circuit> {
  final int id;
  final String name;
  final String? dimmer;
  final String? capacity;
  const Circuit({
    required this.id,
    required this.name,
    this.dimmer,
    this.capacity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dimmer != null) {
      map['dimmer'] = Variable<String>(dimmer);
    }
    if (!nullToAbsent || capacity != null) {
      map['capacity'] = Variable<String>(capacity);
    }
    return map;
  }

  CircuitsCompanion toCompanion(bool nullToAbsent) {
    return CircuitsCompanion(
      id: Value(id),
      name: Value(name),
      dimmer: dimmer == null && nullToAbsent
          ? const Value.absent()
          : Value(dimmer),
      capacity: capacity == null && nullToAbsent
          ? const Value.absent()
          : Value(capacity),
    );
  }

  factory Circuit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Circuit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dimmer: serializer.fromJson<String?>(json['dimmer']),
      capacity: serializer.fromJson<String?>(json['capacity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dimmer': serializer.toJson<String?>(dimmer),
      'capacity': serializer.toJson<String?>(capacity),
    };
  }

  Circuit copyWith({
    int? id,
    String? name,
    Value<String?> dimmer = const Value.absent(),
    Value<String?> capacity = const Value.absent(),
  }) => Circuit(
    id: id ?? this.id,
    name: name ?? this.name,
    dimmer: dimmer.present ? dimmer.value : this.dimmer,
    capacity: capacity.present ? capacity.value : this.capacity,
  );
  Circuit copyWithCompanion(CircuitsCompanion data) {
    return Circuit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dimmer: data.dimmer.present ? data.dimmer.value : this.dimmer,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Circuit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dimmer: $dimmer, ')
          ..write('capacity: $capacity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dimmer, capacity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Circuit &&
          other.id == this.id &&
          other.name == this.name &&
          other.dimmer == this.dimmer &&
          other.capacity == this.capacity);
}

class CircuitsCompanion extends UpdateCompanion<Circuit> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> dimmer;
  final Value<String?> capacity;
  const CircuitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dimmer = const Value.absent(),
    this.capacity = const Value.absent(),
  });
  CircuitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.dimmer = const Value.absent(),
    this.capacity = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Circuit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dimmer,
    Expression<String>? capacity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dimmer != null) 'dimmer': dimmer,
      if (capacity != null) 'capacity': capacity,
    });
  }

  CircuitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? dimmer,
    Value<String?>? capacity,
  }) {
    return CircuitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dimmer: dimmer ?? this.dimmer,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dimmer.present) {
      map['dimmer'] = Variable<String>(dimmer.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<String>(capacity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CircuitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dimmer: $dimmer, ')
          ..write('capacity: $capacity')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels with TableInfo<$ChannelsTable, Channel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Channel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Channel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Channel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class Channel extends DataClass implements Insertable<Channel> {
  final int id;
  final String name;
  final String? notes;
  const Channel({required this.id, required this.name, this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      id: Value(id),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Channel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Channel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Channel copyWith({
    int? id,
    String? name,
    Value<String?> notes = const Value.absent(),
  }) => Channel(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
  );
  Channel copyWithCompanion(ChannelsCompanion data) {
    return Channel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Channel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Channel &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes);
}

class ChannelsCompanion extends UpdateCompanion<Channel> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> notes;
  const ChannelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ChannelsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Channel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
    });
  }

  ChannelsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? notes,
  }) {
    return ChannelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $AddressesTable extends Addresses
    with TableInfo<$AddressesTable, AddressesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, channel];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'addresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<AddressesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AddressesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AddressesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      ),
    );
  }

  @override
  $AddressesTable createAlias(String alias) {
    return $AddressesTable(attachedDatabase, alias);
  }
}

class AddressesData extends DataClass implements Insertable<AddressesData> {
  final int id;
  final String name;
  final String? type;
  final String? channel;
  const AddressesData({
    required this.id,
    required this.name,
    this.type,
    this.channel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || channel != null) {
      map['channel'] = Variable<String>(channel);
    }
    return map;
  }

  AddressesCompanion toCompanion(bool nullToAbsent) {
    return AddressesCompanion(
      id: Value(id),
      name: Value(name),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      channel: channel == null && nullToAbsent
          ? const Value.absent()
          : Value(channel),
    );
  }

  factory AddressesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AddressesData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String?>(json['type']),
      channel: serializer.fromJson<String?>(json['channel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String?>(type),
      'channel': serializer.toJson<String?>(channel),
    };
  }

  AddressesData copyWith({
    int? id,
    String? name,
    Value<String?> type = const Value.absent(),
    Value<String?> channel = const Value.absent(),
  }) => AddressesData(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type.present ? type.value : this.type,
    channel: channel.present ? channel.value : this.channel,
  );
  AddressesData copyWithCompanion(AddressesCompanion data) {
    return AddressesData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      channel: data.channel.present ? data.channel.value : this.channel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AddressesData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('channel: $channel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, channel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AddressesData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.channel == this.channel);
}

class AddressesCompanion extends UpdateCompanion<AddressesData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> type;
  final Value<String?> channel;
  const AddressesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.channel = const Value.absent(),
  });
  AddressesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.channel = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AddressesData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? channel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (channel != null) 'channel': channel,
    });
  }

  AddressesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? type,
    Value<String?>? channel,
  }) {
    return AddressesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      channel: channel ?? this.channel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AddressesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('channel: $channel')
          ..write(')'))
        .toString();
  }
}

class $DimmersTable extends Dimmers with TableInfo<$DimmersTable, Dimmer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DimmersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packMeta = const VerificationMeta('pack');
  @override
  late final GeneratedColumn<String> pack = GeneratedColumn<String>(
    'pack',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rackMeta = const VerificationMeta('rack');
  @override
  late final GeneratedColumn<String> rack = GeneratedColumn<String>(
    'rack',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<String> capacity = GeneratedColumn<String>(
    'capacity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    pack,
    rack,
    location,
    capacity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dimmers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dimmer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('pack')) {
      context.handle(
        _packMeta,
        pack.isAcceptableOrUnknown(data['pack']!, _packMeta),
      );
    }
    if (data.containsKey('rack')) {
      context.handle(
        _rackMeta,
        rack.isAcceptableOrUnknown(data['rack']!, _rackMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dimmer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dimmer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      pack: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack'],
      ),
      rack: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rack'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capacity'],
      ),
    );
  }

  @override
  $DimmersTable createAlias(String alias) {
    return $DimmersTable(attachedDatabase, alias);
  }
}

class Dimmer extends DataClass implements Insertable<Dimmer> {
  final int id;
  final String name;
  final String? address;
  final String? pack;
  final String? rack;
  final String? location;
  final String? capacity;
  const Dimmer({
    required this.id,
    required this.name,
    this.address,
    this.pack,
    this.rack,
    this.location,
    this.capacity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || pack != null) {
      map['pack'] = Variable<String>(pack);
    }
    if (!nullToAbsent || rack != null) {
      map['rack'] = Variable<String>(rack);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || capacity != null) {
      map['capacity'] = Variable<String>(capacity);
    }
    return map;
  }

  DimmersCompanion toCompanion(bool nullToAbsent) {
    return DimmersCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      pack: pack == null && nullToAbsent ? const Value.absent() : Value(pack),
      rack: rack == null && nullToAbsent ? const Value.absent() : Value(rack),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      capacity: capacity == null && nullToAbsent
          ? const Value.absent()
          : Value(capacity),
    );
  }

  factory Dimmer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dimmer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      pack: serializer.fromJson<String?>(json['pack']),
      rack: serializer.fromJson<String?>(json['rack']),
      location: serializer.fromJson<String?>(json['location']),
      capacity: serializer.fromJson<String?>(json['capacity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'pack': serializer.toJson<String?>(pack),
      'rack': serializer.toJson<String?>(rack),
      'location': serializer.toJson<String?>(location),
      'capacity': serializer.toJson<String?>(capacity),
    };
  }

  Dimmer copyWith({
    int? id,
    String? name,
    Value<String?> address = const Value.absent(),
    Value<String?> pack = const Value.absent(),
    Value<String?> rack = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> capacity = const Value.absent(),
  }) => Dimmer(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    pack: pack.present ? pack.value : this.pack,
    rack: rack.present ? rack.value : this.rack,
    location: location.present ? location.value : this.location,
    capacity: capacity.present ? capacity.value : this.capacity,
  );
  Dimmer copyWithCompanion(DimmersCompanion data) {
    return Dimmer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      pack: data.pack.present ? data.pack.value : this.pack,
      rack: data.rack.present ? data.rack.value : this.rack,
      location: data.location.present ? data.location.value : this.location,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dimmer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('pack: $pack, ')
          ..write('rack: $rack, ')
          ..write('location: $location, ')
          ..write('capacity: $capacity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, pack, rack, location, capacity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dimmer &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.pack == this.pack &&
          other.rack == this.rack &&
          other.location == this.location &&
          other.capacity == this.capacity);
}

class DimmersCompanion extends UpdateCompanion<Dimmer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> pack;
  final Value<String?> rack;
  final Value<String?> location;
  final Value<String?> capacity;
  const DimmersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.pack = const Value.absent(),
    this.rack = const Value.absent(),
    this.location = const Value.absent(),
    this.capacity = const Value.absent(),
  });
  DimmersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.address = const Value.absent(),
    this.pack = const Value.absent(),
    this.rack = const Value.absent(),
    this.location = const Value.absent(),
    this.capacity = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Dimmer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? pack,
    Expression<String>? rack,
    Expression<String>? location,
    Expression<String>? capacity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (pack != null) 'pack': pack,
      if (rack != null) 'rack': rack,
      if (location != null) 'location': location,
      if (capacity != null) 'capacity': capacity,
    });
  }

  DimmersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? address,
    Value<String?>? pack,
    Value<String?>? rack,
    Value<String?>? location,
    Value<String?>? capacity,
  }) {
    return DimmersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      pack: pack ?? this.pack,
      rack: rack ?? this.rack,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (pack.present) {
      map['pack'] = Variable<String>(pack.value);
    }
    if (rack.present) {
      map['rack'] = Variable<String>(rack.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<String>(capacity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DimmersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('pack: $pack, ')
          ..write('rack: $rack, ')
          ..write('location: $location, ')
          ..write('capacity: $capacity')
          ..write(')'))
        .toString();
  }
}

class $FixtureTypesTable extends FixtureTypes
    with TableInfo<$FixtureTypesTable, FixtureType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixtureTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wattageMeta = const VerificationMeta(
    'wattage',
  );
  @override
  late final GeneratedColumn<String> wattage = GeneratedColumn<String>(
    'wattage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partCountMeta = const VerificationMeta(
    'partCount',
  );
  @override
  late final GeneratedColumn<int> partCount = GeneratedColumn<int>(
    'part_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultPartsJsonMeta = const VerificationMeta(
    'defaultPartsJson',
  );
  @override
  late final GeneratedColumn<String> defaultPartsJson = GeneratedColumn<String>(
    'default_parts_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    wattage,
    partCount,
    defaultPartsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixture_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixtureType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('wattage')) {
      context.handle(
        _wattageMeta,
        wattage.isAcceptableOrUnknown(data['wattage']!, _wattageMeta),
      );
    }
    if (data.containsKey('part_count')) {
      context.handle(
        _partCountMeta,
        partCount.isAcceptableOrUnknown(data['part_count']!, _partCountMeta),
      );
    }
    if (data.containsKey('default_parts_json')) {
      context.handle(
        _defaultPartsJsonMeta,
        defaultPartsJson.isAcceptableOrUnknown(
          data['default_parts_json']!,
          _defaultPartsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixtureType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixtureType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      wattage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wattage'],
      ),
      partCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_count'],
      )!,
      defaultPartsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_parts_json'],
      ),
    );
  }

  @override
  $FixtureTypesTable createAlias(String alias) {
    return $FixtureTypesTable(attachedDatabase, alias);
  }
}

class FixtureType extends DataClass implements Insertable<FixtureType> {
  final int id;
  final String name;
  final String? wattage;
  final int partCount;
  final String? defaultPartsJson;
  const FixtureType({
    required this.id,
    required this.name,
    this.wattage,
    required this.partCount,
    this.defaultPartsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || wattage != null) {
      map['wattage'] = Variable<String>(wattage);
    }
    map['part_count'] = Variable<int>(partCount);
    if (!nullToAbsent || defaultPartsJson != null) {
      map['default_parts_json'] = Variable<String>(defaultPartsJson);
    }
    return map;
  }

  FixtureTypesCompanion toCompanion(bool nullToAbsent) {
    return FixtureTypesCompanion(
      id: Value(id),
      name: Value(name),
      wattage: wattage == null && nullToAbsent
          ? const Value.absent()
          : Value(wattage),
      partCount: Value(partCount),
      defaultPartsJson: defaultPartsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultPartsJson),
    );
  }

  factory FixtureType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixtureType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      wattage: serializer.fromJson<String?>(json['wattage']),
      partCount: serializer.fromJson<int>(json['partCount']),
      defaultPartsJson: serializer.fromJson<String?>(json['defaultPartsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'wattage': serializer.toJson<String?>(wattage),
      'partCount': serializer.toJson<int>(partCount),
      'defaultPartsJson': serializer.toJson<String?>(defaultPartsJson),
    };
  }

  FixtureType copyWith({
    int? id,
    String? name,
    Value<String?> wattage = const Value.absent(),
    int? partCount,
    Value<String?> defaultPartsJson = const Value.absent(),
  }) => FixtureType(
    id: id ?? this.id,
    name: name ?? this.name,
    wattage: wattage.present ? wattage.value : this.wattage,
    partCount: partCount ?? this.partCount,
    defaultPartsJson: defaultPartsJson.present
        ? defaultPartsJson.value
        : this.defaultPartsJson,
  );
  FixtureType copyWithCompanion(FixtureTypesCompanion data) {
    return FixtureType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      wattage: data.wattage.present ? data.wattage.value : this.wattage,
      partCount: data.partCount.present ? data.partCount.value : this.partCount,
      defaultPartsJson: data.defaultPartsJson.present
          ? data.defaultPartsJson.value
          : this.defaultPartsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixtureType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('wattage: $wattage, ')
          ..write('partCount: $partCount, ')
          ..write('defaultPartsJson: $defaultPartsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, wattage, partCount, defaultPartsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixtureType &&
          other.id == this.id &&
          other.name == this.name &&
          other.wattage == this.wattage &&
          other.partCount == this.partCount &&
          other.defaultPartsJson == this.defaultPartsJson);
}

class FixtureTypesCompanion extends UpdateCompanion<FixtureType> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> wattage;
  final Value<int> partCount;
  final Value<String?> defaultPartsJson;
  const FixtureTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.wattage = const Value.absent(),
    this.partCount = const Value.absent(),
    this.defaultPartsJson = const Value.absent(),
  });
  FixtureTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.wattage = const Value.absent(),
    this.partCount = const Value.absent(),
    this.defaultPartsJson = const Value.absent(),
  }) : name = Value(name);
  static Insertable<FixtureType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? wattage,
    Expression<int>? partCount,
    Expression<String>? defaultPartsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (wattage != null) 'wattage': wattage,
      if (partCount != null) 'part_count': partCount,
      if (defaultPartsJson != null) 'default_parts_json': defaultPartsJson,
    });
  }

  FixtureTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? wattage,
    Value<int>? partCount,
    Value<String?>? defaultPartsJson,
  }) {
    return FixtureTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      wattage: wattage ?? this.wattage,
      partCount: partCount ?? this.partCount,
      defaultPartsJson: defaultPartsJson ?? this.defaultPartsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (wattage.present) {
      map['wattage'] = Variable<String>(wattage.value);
    }
    if (partCount.present) {
      map['part_count'] = Variable<int>(partCount.value);
    }
    if (defaultPartsJson.present) {
      map['default_parts_json'] = Variable<String>(defaultPartsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixtureTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('wattage: $wattage, ')
          ..write('partCount: $partCount, ')
          ..write('defaultPartsJson: $defaultPartsJson')
          ..write(')'))
        .toString();
  }
}

class $FixturesTable extends Fixtures with TableInfo<$FixturesTable, Fixture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fixtureTypeIdMeta = const VerificationMeta(
    'fixtureTypeId',
  );
  @override
  late final GeneratedColumn<int> fixtureTypeId = GeneratedColumn<int>(
    'fixture_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixture_types (id)',
    ),
  );
  static const VerificationMeta _fixtureTypeMeta = const VerificationMeta(
    'fixtureType',
  );
  @override
  late final GeneratedColumn<String> fixtureType = GeneratedColumn<String>(
    'fixture_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitNumberMeta = const VerificationMeta(
    'unitNumber',
  );
  @override
  late final GeneratedColumn<int> unitNumber = GeneratedColumn<int>(
    'unit_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wattageMeta = const VerificationMeta(
    'wattage',
  );
  @override
  late final GeneratedColumn<String> wattage = GeneratedColumn<String>(
    'wattage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _functionMeta = const VerificationMeta(
    'function',
  );
  @override
  late final GeneratedColumn<String> function = GeneratedColumn<String>(
    'function',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
    'focus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flaggedMeta = const VerificationMeta(
    'flagged',
  );
  @override
  late final GeneratedColumn<int> flagged = GeneratedColumn<int>(
    'flagged',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _accessoriesMeta = const VerificationMeta(
    'accessories',
  );
  @override
  late final GeneratedColumn<String> accessories = GeneratedColumn<String>(
    'accessories',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hungMeta = const VerificationMeta('hung');
  @override
  late final GeneratedColumn<int> hung = GeneratedColumn<int>(
    'hung',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _focusedMeta = const VerificationMeta(
    'focused',
  );
  @override
  late final GeneratedColumn<int> focused = GeneratedColumn<int>(
    'focused',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _patchedMeta = const VerificationMeta(
    'patched',
  );
  @override
  late final GeneratedColumn<int> patched = GeneratedColumn<int>(
    'patched',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fixtureTypeId,
    fixtureType,
    position,
    unitNumber,
    wattage,
    function,
    focus,
    flagged,
    sortOrder,
    accessories,
    hung,
    focused,
    patched,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixtures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fixture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fixture_type_id')) {
      context.handle(
        _fixtureTypeIdMeta,
        fixtureTypeId.isAcceptableOrUnknown(
          data['fixture_type_id']!,
          _fixtureTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('fixture_type')) {
      context.handle(
        _fixtureTypeMeta,
        fixtureType.isAcceptableOrUnknown(
          data['fixture_type']!,
          _fixtureTypeMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('unit_number')) {
      context.handle(
        _unitNumberMeta,
        unitNumber.isAcceptableOrUnknown(data['unit_number']!, _unitNumberMeta),
      );
    }
    if (data.containsKey('wattage')) {
      context.handle(
        _wattageMeta,
        wattage.isAcceptableOrUnknown(data['wattage']!, _wattageMeta),
      );
    }
    if (data.containsKey('function')) {
      context.handle(
        _functionMeta,
        function.isAcceptableOrUnknown(data['function']!, _functionMeta),
      );
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    }
    if (data.containsKey('flagged')) {
      context.handle(
        _flaggedMeta,
        flagged.isAcceptableOrUnknown(data['flagged']!, _flaggedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('accessories')) {
      context.handle(
        _accessoriesMeta,
        accessories.isAcceptableOrUnknown(
          data['accessories']!,
          _accessoriesMeta,
        ),
      );
    }
    if (data.containsKey('hung')) {
      context.handle(
        _hungMeta,
        hung.isAcceptableOrUnknown(data['hung']!, _hungMeta),
      );
    }
    if (data.containsKey('focused')) {
      context.handle(
        _focusedMeta,
        focused.isAcceptableOrUnknown(data['focused']!, _focusedMeta),
      );
    }
    if (data.containsKey('patched')) {
      context.handle(
        _patchedMeta,
        patched.isAcceptableOrUnknown(data['patched']!, _patchedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fixture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fixture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fixtureTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_type_id'],
      ),
      fixtureType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fixture_type'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      unitNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_number'],
      ),
      wattage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wattage'],
      ),
      function: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}function'],
      ),
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus'],
      ),
      flagged: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flagged'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_order'],
      )!,
      accessories: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accessories'],
      ),
      hung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hung'],
      )!,
      focused: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focused'],
      )!,
      patched: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patched'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $FixturesTable createAlias(String alias) {
    return $FixturesTable(attachedDatabase, alias);
  }
}

class Fixture extends DataClass implements Insertable<Fixture> {
  final int id;
  final int? fixtureTypeId;
  final String? fixtureType;
  final String? position;
  final int? unitNumber;
  final String? wattage;
  final String? function;
  final String? focus;
  final int flagged;
  final double sortOrder;
  final String? accessories;
  final int hung;
  final int focused;
  final int patched;
  final int deleted;
  const Fixture({
    required this.id,
    this.fixtureTypeId,
    this.fixtureType,
    this.position,
    this.unitNumber,
    this.wattage,
    this.function,
    this.focus,
    required this.flagged,
    required this.sortOrder,
    this.accessories,
    required this.hung,
    required this.focused,
    required this.patched,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || fixtureTypeId != null) {
      map['fixture_type_id'] = Variable<int>(fixtureTypeId);
    }
    if (!nullToAbsent || fixtureType != null) {
      map['fixture_type'] = Variable<String>(fixtureType);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    if (!nullToAbsent || unitNumber != null) {
      map['unit_number'] = Variable<int>(unitNumber);
    }
    if (!nullToAbsent || wattage != null) {
      map['wattage'] = Variable<String>(wattage);
    }
    if (!nullToAbsent || function != null) {
      map['function'] = Variable<String>(function);
    }
    if (!nullToAbsent || focus != null) {
      map['focus'] = Variable<String>(focus);
    }
    map['flagged'] = Variable<int>(flagged);
    map['sort_order'] = Variable<double>(sortOrder);
    if (!nullToAbsent || accessories != null) {
      map['accessories'] = Variable<String>(accessories);
    }
    map['hung'] = Variable<int>(hung);
    map['focused'] = Variable<int>(focused);
    map['patched'] = Variable<int>(patched);
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  FixturesCompanion toCompanion(bool nullToAbsent) {
    return FixturesCompanion(
      id: Value(id),
      fixtureTypeId: fixtureTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixtureTypeId),
      fixtureType: fixtureType == null && nullToAbsent
          ? const Value.absent()
          : Value(fixtureType),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      unitNumber: unitNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(unitNumber),
      wattage: wattage == null && nullToAbsent
          ? const Value.absent()
          : Value(wattage),
      function: function == null && nullToAbsent
          ? const Value.absent()
          : Value(function),
      focus: focus == null && nullToAbsent
          ? const Value.absent()
          : Value(focus),
      flagged: Value(flagged),
      sortOrder: Value(sortOrder),
      accessories: accessories == null && nullToAbsent
          ? const Value.absent()
          : Value(accessories),
      hung: Value(hung),
      focused: Value(focused),
      patched: Value(patched),
      deleted: Value(deleted),
    );
  }

  factory Fixture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fixture(
      id: serializer.fromJson<int>(json['id']),
      fixtureTypeId: serializer.fromJson<int?>(json['fixtureTypeId']),
      fixtureType: serializer.fromJson<String?>(json['fixtureType']),
      position: serializer.fromJson<String?>(json['position']),
      unitNumber: serializer.fromJson<int?>(json['unitNumber']),
      wattage: serializer.fromJson<String?>(json['wattage']),
      function: serializer.fromJson<String?>(json['function']),
      focus: serializer.fromJson<String?>(json['focus']),
      flagged: serializer.fromJson<int>(json['flagged']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      accessories: serializer.fromJson<String?>(json['accessories']),
      hung: serializer.fromJson<int>(json['hung']),
      focused: serializer.fromJson<int>(json['focused']),
      patched: serializer.fromJson<int>(json['patched']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fixtureTypeId': serializer.toJson<int?>(fixtureTypeId),
      'fixtureType': serializer.toJson<String?>(fixtureType),
      'position': serializer.toJson<String?>(position),
      'unitNumber': serializer.toJson<int?>(unitNumber),
      'wattage': serializer.toJson<String?>(wattage),
      'function': serializer.toJson<String?>(function),
      'focus': serializer.toJson<String?>(focus),
      'flagged': serializer.toJson<int>(flagged),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'accessories': serializer.toJson<String?>(accessories),
      'hung': serializer.toJson<int>(hung),
      'focused': serializer.toJson<int>(focused),
      'patched': serializer.toJson<int>(patched),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  Fixture copyWith({
    int? id,
    Value<int?> fixtureTypeId = const Value.absent(),
    Value<String?> fixtureType = const Value.absent(),
    Value<String?> position = const Value.absent(),
    Value<int?> unitNumber = const Value.absent(),
    Value<String?> wattage = const Value.absent(),
    Value<String?> function = const Value.absent(),
    Value<String?> focus = const Value.absent(),
    int? flagged,
    double? sortOrder,
    Value<String?> accessories = const Value.absent(),
    int? hung,
    int? focused,
    int? patched,
    int? deleted,
  }) => Fixture(
    id: id ?? this.id,
    fixtureTypeId: fixtureTypeId.present
        ? fixtureTypeId.value
        : this.fixtureTypeId,
    fixtureType: fixtureType.present ? fixtureType.value : this.fixtureType,
    position: position.present ? position.value : this.position,
    unitNumber: unitNumber.present ? unitNumber.value : this.unitNumber,
    wattage: wattage.present ? wattage.value : this.wattage,
    function: function.present ? function.value : this.function,
    focus: focus.present ? focus.value : this.focus,
    flagged: flagged ?? this.flagged,
    sortOrder: sortOrder ?? this.sortOrder,
    accessories: accessories.present ? accessories.value : this.accessories,
    hung: hung ?? this.hung,
    focused: focused ?? this.focused,
    patched: patched ?? this.patched,
    deleted: deleted ?? this.deleted,
  );
  Fixture copyWithCompanion(FixturesCompanion data) {
    return Fixture(
      id: data.id.present ? data.id.value : this.id,
      fixtureTypeId: data.fixtureTypeId.present
          ? data.fixtureTypeId.value
          : this.fixtureTypeId,
      fixtureType: data.fixtureType.present
          ? data.fixtureType.value
          : this.fixtureType,
      position: data.position.present ? data.position.value : this.position,
      unitNumber: data.unitNumber.present
          ? data.unitNumber.value
          : this.unitNumber,
      wattage: data.wattage.present ? data.wattage.value : this.wattage,
      function: data.function.present ? data.function.value : this.function,
      focus: data.focus.present ? data.focus.value : this.focus,
      flagged: data.flagged.present ? data.flagged.value : this.flagged,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      accessories: data.accessories.present
          ? data.accessories.value
          : this.accessories,
      hung: data.hung.present ? data.hung.value : this.hung,
      focused: data.focused.present ? data.focused.value : this.focused,
      patched: data.patched.present ? data.patched.value : this.patched,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fixture(')
          ..write('id: $id, ')
          ..write('fixtureTypeId: $fixtureTypeId, ')
          ..write('fixtureType: $fixtureType, ')
          ..write('position: $position, ')
          ..write('unitNumber: $unitNumber, ')
          ..write('wattage: $wattage, ')
          ..write('function: $function, ')
          ..write('focus: $focus, ')
          ..write('flagged: $flagged, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('accessories: $accessories, ')
          ..write('hung: $hung, ')
          ..write('focused: $focused, ')
          ..write('patched: $patched, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fixtureTypeId,
    fixtureType,
    position,
    unitNumber,
    wattage,
    function,
    focus,
    flagged,
    sortOrder,
    accessories,
    hung,
    focused,
    patched,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fixture &&
          other.id == this.id &&
          other.fixtureTypeId == this.fixtureTypeId &&
          other.fixtureType == this.fixtureType &&
          other.position == this.position &&
          other.unitNumber == this.unitNumber &&
          other.wattage == this.wattage &&
          other.function == this.function &&
          other.focus == this.focus &&
          other.flagged == this.flagged &&
          other.sortOrder == this.sortOrder &&
          other.accessories == this.accessories &&
          other.hung == this.hung &&
          other.focused == this.focused &&
          other.patched == this.patched &&
          other.deleted == this.deleted);
}

class FixturesCompanion extends UpdateCompanion<Fixture> {
  final Value<int> id;
  final Value<int?> fixtureTypeId;
  final Value<String?> fixtureType;
  final Value<String?> position;
  final Value<int?> unitNumber;
  final Value<String?> wattage;
  final Value<String?> function;
  final Value<String?> focus;
  final Value<int> flagged;
  final Value<double> sortOrder;
  final Value<String?> accessories;
  final Value<int> hung;
  final Value<int> focused;
  final Value<int> patched;
  final Value<int> deleted;
  const FixturesCompanion({
    this.id = const Value.absent(),
    this.fixtureTypeId = const Value.absent(),
    this.fixtureType = const Value.absent(),
    this.position = const Value.absent(),
    this.unitNumber = const Value.absent(),
    this.wattage = const Value.absent(),
    this.function = const Value.absent(),
    this.focus = const Value.absent(),
    this.flagged = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.accessories = const Value.absent(),
    this.hung = const Value.absent(),
    this.focused = const Value.absent(),
    this.patched = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  FixturesCompanion.insert({
    this.id = const Value.absent(),
    this.fixtureTypeId = const Value.absent(),
    this.fixtureType = const Value.absent(),
    this.position = const Value.absent(),
    this.unitNumber = const Value.absent(),
    this.wattage = const Value.absent(),
    this.function = const Value.absent(),
    this.focus = const Value.absent(),
    this.flagged = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.accessories = const Value.absent(),
    this.hung = const Value.absent(),
    this.focused = const Value.absent(),
    this.patched = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  static Insertable<Fixture> custom({
    Expression<int>? id,
    Expression<int>? fixtureTypeId,
    Expression<String>? fixtureType,
    Expression<String>? position,
    Expression<int>? unitNumber,
    Expression<String>? wattage,
    Expression<String>? function,
    Expression<String>? focus,
    Expression<int>? flagged,
    Expression<double>? sortOrder,
    Expression<String>? accessories,
    Expression<int>? hung,
    Expression<int>? focused,
    Expression<int>? patched,
    Expression<int>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fixtureTypeId != null) 'fixture_type_id': fixtureTypeId,
      if (fixtureType != null) 'fixture_type': fixtureType,
      if (position != null) 'position': position,
      if (unitNumber != null) 'unit_number': unitNumber,
      if (wattage != null) 'wattage': wattage,
      if (function != null) 'function': function,
      if (focus != null) 'focus': focus,
      if (flagged != null) 'flagged': flagged,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (accessories != null) 'accessories': accessories,
      if (hung != null) 'hung': hung,
      if (focused != null) 'focused': focused,
      if (patched != null) 'patched': patched,
      if (deleted != null) 'deleted': deleted,
    });
  }

  FixturesCompanion copyWith({
    Value<int>? id,
    Value<int?>? fixtureTypeId,
    Value<String?>? fixtureType,
    Value<String?>? position,
    Value<int?>? unitNumber,
    Value<String?>? wattage,
    Value<String?>? function,
    Value<String?>? focus,
    Value<int>? flagged,
    Value<double>? sortOrder,
    Value<String?>? accessories,
    Value<int>? hung,
    Value<int>? focused,
    Value<int>? patched,
    Value<int>? deleted,
  }) {
    return FixturesCompanion(
      id: id ?? this.id,
      fixtureTypeId: fixtureTypeId ?? this.fixtureTypeId,
      fixtureType: fixtureType ?? this.fixtureType,
      position: position ?? this.position,
      unitNumber: unitNumber ?? this.unitNumber,
      wattage: wattage ?? this.wattage,
      function: function ?? this.function,
      focus: focus ?? this.focus,
      flagged: flagged ?? this.flagged,
      sortOrder: sortOrder ?? this.sortOrder,
      accessories: accessories ?? this.accessories,
      hung: hung ?? this.hung,
      focused: focused ?? this.focused,
      patched: patched ?? this.patched,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fixtureTypeId.present) {
      map['fixture_type_id'] = Variable<int>(fixtureTypeId.value);
    }
    if (fixtureType.present) {
      map['fixture_type'] = Variable<String>(fixtureType.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (unitNumber.present) {
      map['unit_number'] = Variable<int>(unitNumber.value);
    }
    if (wattage.present) {
      map['wattage'] = Variable<String>(wattage.value);
    }
    if (function.present) {
      map['function'] = Variable<String>(function.value);
    }
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (flagged.present) {
      map['flagged'] = Variable<int>(flagged.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (accessories.present) {
      map['accessories'] = Variable<String>(accessories.value);
    }
    if (hung.present) {
      map['hung'] = Variable<int>(hung.value);
    }
    if (focused.present) {
      map['focused'] = Variable<int>(focused.value);
    }
    if (patched.present) {
      map['patched'] = Variable<int>(patched.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixturesCompanion(')
          ..write('id: $id, ')
          ..write('fixtureTypeId: $fixtureTypeId, ')
          ..write('fixtureType: $fixtureType, ')
          ..write('position: $position, ')
          ..write('unitNumber: $unitNumber, ')
          ..write('wattage: $wattage, ')
          ..write('function: $function, ')
          ..write('focus: $focus, ')
          ..write('flagged: $flagged, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('accessories: $accessories, ')
          ..write('hung: $hung, ')
          ..write('focused: $focused, ')
          ..write('patched: $patched, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $FixturePartsTable extends FixtureParts
    with TableInfo<$FixturePartsTable, FixturePart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixturePartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _partOrderMeta = const VerificationMeta(
    'partOrder',
  );
  @override
  late final GeneratedColumn<int> partOrder = GeneratedColumn<int>(
    'part_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partTypeMeta = const VerificationMeta(
    'partType',
  );
  @override
  late final GeneratedColumn<String> partType = GeneratedColumn<String>(
    'part_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (part_type IN (\'intensity\',\'gel\',\'x\',\'y\',\'x_high\',\'x_low\',\'y_high\',\'y_low\',\'gobo\',\'gobo_feature\',\'color_feature\'))',
  );
  static const VerificationMeta _partNameMeta = const VerificationMeta(
    'partName',
  );
  @override
  late final GeneratedColumn<String> partName = GeneratedColumn<String>(
    'part_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _circuitMeta = const VerificationMeta(
    'circuit',
  );
  @override
  late final GeneratedColumn<String> circuit = GeneratedColumn<String>(
    'circuit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _macAddressMeta = const VerificationMeta(
    'macAddress',
  );
  @override
  late final GeneratedColumn<String> macAddress = GeneratedColumn<String>(
    'mac_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subnetMeta = const VerificationMeta('subnet');
  @override
  late final GeneratedColumn<String> subnet = GeneratedColumn<String>(
    'subnet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ipv6Meta = const VerificationMeta('ipv6');
  @override
  late final GeneratedColumn<String> ipv6 = GeneratedColumn<String>(
    'ipv6',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extrasJsonMeta = const VerificationMeta(
    'extrasJson',
  );
  @override
  late final GeneratedColumn<String> extrasJson = GeneratedColumn<String>(
    'extras_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<int> deleted = GeneratedColumn<int>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fixtureId,
    partOrder,
    partType,
    partName,
    channel,
    address,
    circuit,
    ipAddress,
    macAddress,
    subnet,
    ipv6,
    extrasJson,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixture_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixturePart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    if (data.containsKey('part_order')) {
      context.handle(
        _partOrderMeta,
        partOrder.isAcceptableOrUnknown(data['part_order']!, _partOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_partOrderMeta);
    }
    if (data.containsKey('part_type')) {
      context.handle(
        _partTypeMeta,
        partType.isAcceptableOrUnknown(data['part_type']!, _partTypeMeta),
      );
    }
    if (data.containsKey('part_name')) {
      context.handle(
        _partNameMeta,
        partName.isAcceptableOrUnknown(data['part_name']!, _partNameMeta),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('circuit')) {
      context.handle(
        _circuitMeta,
        circuit.isAcceptableOrUnknown(data['circuit']!, _circuitMeta),
      );
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    }
    if (data.containsKey('mac_address')) {
      context.handle(
        _macAddressMeta,
        macAddress.isAcceptableOrUnknown(data['mac_address']!, _macAddressMeta),
      );
    }
    if (data.containsKey('subnet')) {
      context.handle(
        _subnetMeta,
        subnet.isAcceptableOrUnknown(data['subnet']!, _subnetMeta),
      );
    }
    if (data.containsKey('ipv6')) {
      context.handle(
        _ipv6Meta,
        ipv6.isAcceptableOrUnknown(data['ipv6']!, _ipv6Meta),
      );
    }
    if (data.containsKey('extras_json')) {
      context.handle(
        _extrasJsonMeta,
        extrasJson.isAcceptableOrUnknown(data['extras_json']!, _extrasJsonMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixturePart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixturePart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      )!,
      partOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_order'],
      )!,
      partType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_type'],
      ),
      partName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_name'],
      ),
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      circuit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circuit'],
      ),
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      ),
      macAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mac_address'],
      ),
      subnet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subnet'],
      ),
      ipv6: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipv6'],
      ),
      extrasJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extras_json'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $FixturePartsTable createAlias(String alias) {
    return $FixturePartsTable(attachedDatabase, alias);
  }
}

class FixturePart extends DataClass implements Insertable<FixturePart> {
  final int id;
  final int fixtureId;
  final int partOrder;
  final String? partType;
  final String? partName;
  final String? channel;
  final String? address;
  final String? circuit;
  final String? ipAddress;
  final String? macAddress;
  final String? subnet;
  final String? ipv6;
  final String? extrasJson;
  final int deleted;
  const FixturePart({
    required this.id,
    required this.fixtureId,
    required this.partOrder,
    this.partType,
    this.partName,
    this.channel,
    this.address,
    this.circuit,
    this.ipAddress,
    this.macAddress,
    this.subnet,
    this.ipv6,
    this.extrasJson,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fixture_id'] = Variable<int>(fixtureId);
    map['part_order'] = Variable<int>(partOrder);
    if (!nullToAbsent || partType != null) {
      map['part_type'] = Variable<String>(partType);
    }
    if (!nullToAbsent || partName != null) {
      map['part_name'] = Variable<String>(partName);
    }
    if (!nullToAbsent || channel != null) {
      map['channel'] = Variable<String>(channel);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || circuit != null) {
      map['circuit'] = Variable<String>(circuit);
    }
    if (!nullToAbsent || ipAddress != null) {
      map['ip_address'] = Variable<String>(ipAddress);
    }
    if (!nullToAbsent || macAddress != null) {
      map['mac_address'] = Variable<String>(macAddress);
    }
    if (!nullToAbsent || subnet != null) {
      map['subnet'] = Variable<String>(subnet);
    }
    if (!nullToAbsent || ipv6 != null) {
      map['ipv6'] = Variable<String>(ipv6);
    }
    if (!nullToAbsent || extrasJson != null) {
      map['extras_json'] = Variable<String>(extrasJson);
    }
    map['deleted'] = Variable<int>(deleted);
    return map;
  }

  FixturePartsCompanion toCompanion(bool nullToAbsent) {
    return FixturePartsCompanion(
      id: Value(id),
      fixtureId: Value(fixtureId),
      partOrder: Value(partOrder),
      partType: partType == null && nullToAbsent
          ? const Value.absent()
          : Value(partType),
      partName: partName == null && nullToAbsent
          ? const Value.absent()
          : Value(partName),
      channel: channel == null && nullToAbsent
          ? const Value.absent()
          : Value(channel),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      circuit: circuit == null && nullToAbsent
          ? const Value.absent()
          : Value(circuit),
      ipAddress: ipAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(ipAddress),
      macAddress: macAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(macAddress),
      subnet: subnet == null && nullToAbsent
          ? const Value.absent()
          : Value(subnet),
      ipv6: ipv6 == null && nullToAbsent ? const Value.absent() : Value(ipv6),
      extrasJson: extrasJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extrasJson),
      deleted: Value(deleted),
    );
  }

  factory FixturePart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixturePart(
      id: serializer.fromJson<int>(json['id']),
      fixtureId: serializer.fromJson<int>(json['fixtureId']),
      partOrder: serializer.fromJson<int>(json['partOrder']),
      partType: serializer.fromJson<String?>(json['partType']),
      partName: serializer.fromJson<String?>(json['partName']),
      channel: serializer.fromJson<String?>(json['channel']),
      address: serializer.fromJson<String?>(json['address']),
      circuit: serializer.fromJson<String?>(json['circuit']),
      ipAddress: serializer.fromJson<String?>(json['ipAddress']),
      macAddress: serializer.fromJson<String?>(json['macAddress']),
      subnet: serializer.fromJson<String?>(json['subnet']),
      ipv6: serializer.fromJson<String?>(json['ipv6']),
      extrasJson: serializer.fromJson<String?>(json['extrasJson']),
      deleted: serializer.fromJson<int>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fixtureId': serializer.toJson<int>(fixtureId),
      'partOrder': serializer.toJson<int>(partOrder),
      'partType': serializer.toJson<String?>(partType),
      'partName': serializer.toJson<String?>(partName),
      'channel': serializer.toJson<String?>(channel),
      'address': serializer.toJson<String?>(address),
      'circuit': serializer.toJson<String?>(circuit),
      'ipAddress': serializer.toJson<String?>(ipAddress),
      'macAddress': serializer.toJson<String?>(macAddress),
      'subnet': serializer.toJson<String?>(subnet),
      'ipv6': serializer.toJson<String?>(ipv6),
      'extrasJson': serializer.toJson<String?>(extrasJson),
      'deleted': serializer.toJson<int>(deleted),
    };
  }

  FixturePart copyWith({
    int? id,
    int? fixtureId,
    int? partOrder,
    Value<String?> partType = const Value.absent(),
    Value<String?> partName = const Value.absent(),
    Value<String?> channel = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> circuit = const Value.absent(),
    Value<String?> ipAddress = const Value.absent(),
    Value<String?> macAddress = const Value.absent(),
    Value<String?> subnet = const Value.absent(),
    Value<String?> ipv6 = const Value.absent(),
    Value<String?> extrasJson = const Value.absent(),
    int? deleted,
  }) => FixturePart(
    id: id ?? this.id,
    fixtureId: fixtureId ?? this.fixtureId,
    partOrder: partOrder ?? this.partOrder,
    partType: partType.present ? partType.value : this.partType,
    partName: partName.present ? partName.value : this.partName,
    channel: channel.present ? channel.value : this.channel,
    address: address.present ? address.value : this.address,
    circuit: circuit.present ? circuit.value : this.circuit,
    ipAddress: ipAddress.present ? ipAddress.value : this.ipAddress,
    macAddress: macAddress.present ? macAddress.value : this.macAddress,
    subnet: subnet.present ? subnet.value : this.subnet,
    ipv6: ipv6.present ? ipv6.value : this.ipv6,
    extrasJson: extrasJson.present ? extrasJson.value : this.extrasJson,
    deleted: deleted ?? this.deleted,
  );
  FixturePart copyWithCompanion(FixturePartsCompanion data) {
    return FixturePart(
      id: data.id.present ? data.id.value : this.id,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      partOrder: data.partOrder.present ? data.partOrder.value : this.partOrder,
      partType: data.partType.present ? data.partType.value : this.partType,
      partName: data.partName.present ? data.partName.value : this.partName,
      channel: data.channel.present ? data.channel.value : this.channel,
      address: data.address.present ? data.address.value : this.address,
      circuit: data.circuit.present ? data.circuit.value : this.circuit,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      macAddress: data.macAddress.present
          ? data.macAddress.value
          : this.macAddress,
      subnet: data.subnet.present ? data.subnet.value : this.subnet,
      ipv6: data.ipv6.present ? data.ipv6.value : this.ipv6,
      extrasJson: data.extrasJson.present
          ? data.extrasJson.value
          : this.extrasJson,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixturePart(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('partOrder: $partOrder, ')
          ..write('partType: $partType, ')
          ..write('partName: $partName, ')
          ..write('channel: $channel, ')
          ..write('address: $address, ')
          ..write('circuit: $circuit, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('macAddress: $macAddress, ')
          ..write('subnet: $subnet, ')
          ..write('ipv6: $ipv6, ')
          ..write('extrasJson: $extrasJson, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fixtureId,
    partOrder,
    partType,
    partName,
    channel,
    address,
    circuit,
    ipAddress,
    macAddress,
    subnet,
    ipv6,
    extrasJson,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixturePart &&
          other.id == this.id &&
          other.fixtureId == this.fixtureId &&
          other.partOrder == this.partOrder &&
          other.partType == this.partType &&
          other.partName == this.partName &&
          other.channel == this.channel &&
          other.address == this.address &&
          other.circuit == this.circuit &&
          other.ipAddress == this.ipAddress &&
          other.macAddress == this.macAddress &&
          other.subnet == this.subnet &&
          other.ipv6 == this.ipv6 &&
          other.extrasJson == this.extrasJson &&
          other.deleted == this.deleted);
}

class FixturePartsCompanion extends UpdateCompanion<FixturePart> {
  final Value<int> id;
  final Value<int> fixtureId;
  final Value<int> partOrder;
  final Value<String?> partType;
  final Value<String?> partName;
  final Value<String?> channel;
  final Value<String?> address;
  final Value<String?> circuit;
  final Value<String?> ipAddress;
  final Value<String?> macAddress;
  final Value<String?> subnet;
  final Value<String?> ipv6;
  final Value<String?> extrasJson;
  final Value<int> deleted;
  const FixturePartsCompanion({
    this.id = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.partOrder = const Value.absent(),
    this.partType = const Value.absent(),
    this.partName = const Value.absent(),
    this.channel = const Value.absent(),
    this.address = const Value.absent(),
    this.circuit = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.macAddress = const Value.absent(),
    this.subnet = const Value.absent(),
    this.ipv6 = const Value.absent(),
    this.extrasJson = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  FixturePartsCompanion.insert({
    this.id = const Value.absent(),
    required int fixtureId,
    required int partOrder,
    this.partType = const Value.absent(),
    this.partName = const Value.absent(),
    this.channel = const Value.absent(),
    this.address = const Value.absent(),
    this.circuit = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.macAddress = const Value.absent(),
    this.subnet = const Value.absent(),
    this.ipv6 = const Value.absent(),
    this.extrasJson = const Value.absent(),
    this.deleted = const Value.absent(),
  }) : fixtureId = Value(fixtureId),
       partOrder = Value(partOrder);
  static Insertable<FixturePart> custom({
    Expression<int>? id,
    Expression<int>? fixtureId,
    Expression<int>? partOrder,
    Expression<String>? partType,
    Expression<String>? partName,
    Expression<String>? channel,
    Expression<String>? address,
    Expression<String>? circuit,
    Expression<String>? ipAddress,
    Expression<String>? macAddress,
    Expression<String>? subnet,
    Expression<String>? ipv6,
    Expression<String>? extrasJson,
    Expression<int>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (partOrder != null) 'part_order': partOrder,
      if (partType != null) 'part_type': partType,
      if (partName != null) 'part_name': partName,
      if (channel != null) 'channel': channel,
      if (address != null) 'address': address,
      if (circuit != null) 'circuit': circuit,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (macAddress != null) 'mac_address': macAddress,
      if (subnet != null) 'subnet': subnet,
      if (ipv6 != null) 'ipv6': ipv6,
      if (extrasJson != null) 'extras_json': extrasJson,
      if (deleted != null) 'deleted': deleted,
    });
  }

  FixturePartsCompanion copyWith({
    Value<int>? id,
    Value<int>? fixtureId,
    Value<int>? partOrder,
    Value<String?>? partType,
    Value<String?>? partName,
    Value<String?>? channel,
    Value<String?>? address,
    Value<String?>? circuit,
    Value<String?>? ipAddress,
    Value<String?>? macAddress,
    Value<String?>? subnet,
    Value<String?>? ipv6,
    Value<String?>? extrasJson,
    Value<int>? deleted,
  }) {
    return FixturePartsCompanion(
      id: id ?? this.id,
      fixtureId: fixtureId ?? this.fixtureId,
      partOrder: partOrder ?? this.partOrder,
      partType: partType ?? this.partType,
      partName: partName ?? this.partName,
      channel: channel ?? this.channel,
      address: address ?? this.address,
      circuit: circuit ?? this.circuit,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      subnet: subnet ?? this.subnet,
      ipv6: ipv6 ?? this.ipv6,
      extrasJson: extrasJson ?? this.extrasJson,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    if (partOrder.present) {
      map['part_order'] = Variable<int>(partOrder.value);
    }
    if (partType.present) {
      map['part_type'] = Variable<String>(partType.value);
    }
    if (partName.present) {
      map['part_name'] = Variable<String>(partName.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (circuit.present) {
      map['circuit'] = Variable<String>(circuit.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (macAddress.present) {
      map['mac_address'] = Variable<String>(macAddress.value);
    }
    if (subnet.present) {
      map['subnet'] = Variable<String>(subnet.value);
    }
    if (ipv6.present) {
      map['ipv6'] = Variable<String>(ipv6.value);
    }
    if (extrasJson.present) {
      map['extras_json'] = Variable<String>(extrasJson.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<int>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixturePartsCompanion(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('partOrder: $partOrder, ')
          ..write('partType: $partType, ')
          ..write('partName: $partName, ')
          ..write('channel: $channel, ')
          ..write('address: $address, ')
          ..write('circuit: $circuit, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('macAddress: $macAddress, ')
          ..write('subnet: $subnet, ')
          ..write('ipv6: $ipv6, ')
          ..write('extrasJson: $extrasJson, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $GelsTable extends Gels with TableInfo<$GelsTable, Gel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fixturePartIdMeta = const VerificationMeta(
    'fixturePartId',
  );
  @override
  late final GeneratedColumn<int> fixturePartId = GeneratedColumn<int>(
    'fixture_part_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixture_parts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _makerMeta = const VerificationMeta('maker');
  @override
  late final GeneratedColumn<String> maker = GeneratedColumn<String>(
    'maker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    color,
    fixtureId,
    fixturePartId,
    size,
    maker,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    if (data.containsKey('fixture_part_id')) {
      context.handle(
        _fixturePartIdMeta,
        fixturePartId.isAcceptableOrUnknown(
          data['fixture_part_id']!,
          _fixturePartIdMeta,
        ),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('maker')) {
      context.handle(
        _makerMeta,
        maker.isAcceptableOrUnknown(data['maker']!, _makerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      )!,
      fixturePartId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_part_id'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      maker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maker'],
      ),
    );
  }

  @override
  $GelsTable createAlias(String alias) {
    return $GelsTable(attachedDatabase, alias);
  }
}

class Gel extends DataClass implements Insertable<Gel> {
  final int id;
  final String color;
  final int fixtureId;
  final int? fixturePartId;
  final String? size;
  final String? maker;
  const Gel({
    required this.id,
    required this.color,
    required this.fixtureId,
    this.fixturePartId,
    this.size,
    this.maker,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['color'] = Variable<String>(color);
    map['fixture_id'] = Variable<int>(fixtureId);
    if (!nullToAbsent || fixturePartId != null) {
      map['fixture_part_id'] = Variable<int>(fixturePartId);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || maker != null) {
      map['maker'] = Variable<String>(maker);
    }
    return map;
  }

  GelsCompanion toCompanion(bool nullToAbsent) {
    return GelsCompanion(
      id: Value(id),
      color: Value(color),
      fixtureId: Value(fixtureId),
      fixturePartId: fixturePartId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixturePartId),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      maker: maker == null && nullToAbsent
          ? const Value.absent()
          : Value(maker),
    );
  }

  factory Gel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gel(
      id: serializer.fromJson<int>(json['id']),
      color: serializer.fromJson<String>(json['color']),
      fixtureId: serializer.fromJson<int>(json['fixtureId']),
      fixturePartId: serializer.fromJson<int?>(json['fixturePartId']),
      size: serializer.fromJson<String?>(json['size']),
      maker: serializer.fromJson<String?>(json['maker']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'color': serializer.toJson<String>(color),
      'fixtureId': serializer.toJson<int>(fixtureId),
      'fixturePartId': serializer.toJson<int?>(fixturePartId),
      'size': serializer.toJson<String?>(size),
      'maker': serializer.toJson<String?>(maker),
    };
  }

  Gel copyWith({
    int? id,
    String? color,
    int? fixtureId,
    Value<int?> fixturePartId = const Value.absent(),
    Value<String?> size = const Value.absent(),
    Value<String?> maker = const Value.absent(),
  }) => Gel(
    id: id ?? this.id,
    color: color ?? this.color,
    fixtureId: fixtureId ?? this.fixtureId,
    fixturePartId: fixturePartId.present
        ? fixturePartId.value
        : this.fixturePartId,
    size: size.present ? size.value : this.size,
    maker: maker.present ? maker.value : this.maker,
  );
  Gel copyWithCompanion(GelsCompanion data) {
    return Gel(
      id: data.id.present ? data.id.value : this.id,
      color: data.color.present ? data.color.value : this.color,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      fixturePartId: data.fixturePartId.present
          ? data.fixturePartId.value
          : this.fixturePartId,
      size: data.size.present ? data.size.value : this.size,
      maker: data.maker.present ? data.maker.value : this.maker,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gel(')
          ..write('id: $id, ')
          ..write('color: $color, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('fixturePartId: $fixturePartId, ')
          ..write('size: $size, ')
          ..write('maker: $maker')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, color, fixtureId, fixturePartId, size, maker);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gel &&
          other.id == this.id &&
          other.color == this.color &&
          other.fixtureId == this.fixtureId &&
          other.fixturePartId == this.fixturePartId &&
          other.size == this.size &&
          other.maker == this.maker);
}

class GelsCompanion extends UpdateCompanion<Gel> {
  final Value<int> id;
  final Value<String> color;
  final Value<int> fixtureId;
  final Value<int?> fixturePartId;
  final Value<String?> size;
  final Value<String?> maker;
  const GelsCompanion({
    this.id = const Value.absent(),
    this.color = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.fixturePartId = const Value.absent(),
    this.size = const Value.absent(),
    this.maker = const Value.absent(),
  });
  GelsCompanion.insert({
    this.id = const Value.absent(),
    required String color,
    required int fixtureId,
    this.fixturePartId = const Value.absent(),
    this.size = const Value.absent(),
    this.maker = const Value.absent(),
  }) : color = Value(color),
       fixtureId = Value(fixtureId);
  static Insertable<Gel> custom({
    Expression<int>? id,
    Expression<String>? color,
    Expression<int>? fixtureId,
    Expression<int>? fixturePartId,
    Expression<String>? size,
    Expression<String>? maker,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (color != null) 'color': color,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (fixturePartId != null) 'fixture_part_id': fixturePartId,
      if (size != null) 'size': size,
      if (maker != null) 'maker': maker,
    });
  }

  GelsCompanion copyWith({
    Value<int>? id,
    Value<String>? color,
    Value<int>? fixtureId,
    Value<int?>? fixturePartId,
    Value<String?>? size,
    Value<String?>? maker,
  }) {
    return GelsCompanion(
      id: id ?? this.id,
      color: color ?? this.color,
      fixtureId: fixtureId ?? this.fixtureId,
      fixturePartId: fixturePartId ?? this.fixturePartId,
      size: size ?? this.size,
      maker: maker ?? this.maker,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    if (fixturePartId.present) {
      map['fixture_part_id'] = Variable<int>(fixturePartId.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (maker.present) {
      map['maker'] = Variable<String>(maker.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GelsCompanion(')
          ..write('id: $id, ')
          ..write('color: $color, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('fixturePartId: $fixturePartId, ')
          ..write('size: $size, ')
          ..write('maker: $maker')
          ..write(')'))
        .toString();
  }
}

class $GobosTable extends Gobos with TableInfo<$GobosTable, Gobo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GobosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goboNumberMeta = const VerificationMeta(
    'goboNumber',
  );
  @override
  late final GeneratedColumn<String> goboNumber = GeneratedColumn<String>(
    'gobo_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fixturePartIdMeta = const VerificationMeta(
    'fixturePartId',
  );
  @override
  late final GeneratedColumn<int> fixturePartId = GeneratedColumn<int>(
    'fixture_part_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixture_parts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _makerMeta = const VerificationMeta('maker');
  @override
  late final GeneratedColumn<String> maker = GeneratedColumn<String>(
    'maker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goboNumber,
    fixtureId,
    fixturePartId,
    size,
    maker,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gobos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gobo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('gobo_number')) {
      context.handle(
        _goboNumberMeta,
        goboNumber.isAcceptableOrUnknown(data['gobo_number']!, _goboNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_goboNumberMeta);
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    if (data.containsKey('fixture_part_id')) {
      context.handle(
        _fixturePartIdMeta,
        fixturePartId.isAcceptableOrUnknown(
          data['fixture_part_id']!,
          _fixturePartIdMeta,
        ),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('maker')) {
      context.handle(
        _makerMeta,
        maker.isAcceptableOrUnknown(data['maker']!, _makerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gobo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gobo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goboNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gobo_number'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      )!,
      fixturePartId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_part_id'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      maker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maker'],
      ),
    );
  }

  @override
  $GobosTable createAlias(String alias) {
    return $GobosTable(attachedDatabase, alias);
  }
}

class Gobo extends DataClass implements Insertable<Gobo> {
  final int id;
  final String goboNumber;
  final int fixtureId;
  final int? fixturePartId;
  final String? size;
  final String? maker;
  const Gobo({
    required this.id,
    required this.goboNumber,
    required this.fixtureId,
    this.fixturePartId,
    this.size,
    this.maker,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['gobo_number'] = Variable<String>(goboNumber);
    map['fixture_id'] = Variable<int>(fixtureId);
    if (!nullToAbsent || fixturePartId != null) {
      map['fixture_part_id'] = Variable<int>(fixturePartId);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || maker != null) {
      map['maker'] = Variable<String>(maker);
    }
    return map;
  }

  GobosCompanion toCompanion(bool nullToAbsent) {
    return GobosCompanion(
      id: Value(id),
      goboNumber: Value(goboNumber),
      fixtureId: Value(fixtureId),
      fixturePartId: fixturePartId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixturePartId),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      maker: maker == null && nullToAbsent
          ? const Value.absent()
          : Value(maker),
    );
  }

  factory Gobo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gobo(
      id: serializer.fromJson<int>(json['id']),
      goboNumber: serializer.fromJson<String>(json['goboNumber']),
      fixtureId: serializer.fromJson<int>(json['fixtureId']),
      fixturePartId: serializer.fromJson<int?>(json['fixturePartId']),
      size: serializer.fromJson<String?>(json['size']),
      maker: serializer.fromJson<String?>(json['maker']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goboNumber': serializer.toJson<String>(goboNumber),
      'fixtureId': serializer.toJson<int>(fixtureId),
      'fixturePartId': serializer.toJson<int?>(fixturePartId),
      'size': serializer.toJson<String?>(size),
      'maker': serializer.toJson<String?>(maker),
    };
  }

  Gobo copyWith({
    int? id,
    String? goboNumber,
    int? fixtureId,
    Value<int?> fixturePartId = const Value.absent(),
    Value<String?> size = const Value.absent(),
    Value<String?> maker = const Value.absent(),
  }) => Gobo(
    id: id ?? this.id,
    goboNumber: goboNumber ?? this.goboNumber,
    fixtureId: fixtureId ?? this.fixtureId,
    fixturePartId: fixturePartId.present
        ? fixturePartId.value
        : this.fixturePartId,
    size: size.present ? size.value : this.size,
    maker: maker.present ? maker.value : this.maker,
  );
  Gobo copyWithCompanion(GobosCompanion data) {
    return Gobo(
      id: data.id.present ? data.id.value : this.id,
      goboNumber: data.goboNumber.present
          ? data.goboNumber.value
          : this.goboNumber,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      fixturePartId: data.fixturePartId.present
          ? data.fixturePartId.value
          : this.fixturePartId,
      size: data.size.present ? data.size.value : this.size,
      maker: data.maker.present ? data.maker.value : this.maker,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gobo(')
          ..write('id: $id, ')
          ..write('goboNumber: $goboNumber, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('fixturePartId: $fixturePartId, ')
          ..write('size: $size, ')
          ..write('maker: $maker')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, goboNumber, fixtureId, fixturePartId, size, maker);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gobo &&
          other.id == this.id &&
          other.goboNumber == this.goboNumber &&
          other.fixtureId == this.fixtureId &&
          other.fixturePartId == this.fixturePartId &&
          other.size == this.size &&
          other.maker == this.maker);
}

class GobosCompanion extends UpdateCompanion<Gobo> {
  final Value<int> id;
  final Value<String> goboNumber;
  final Value<int> fixtureId;
  final Value<int?> fixturePartId;
  final Value<String?> size;
  final Value<String?> maker;
  const GobosCompanion({
    this.id = const Value.absent(),
    this.goboNumber = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.fixturePartId = const Value.absent(),
    this.size = const Value.absent(),
    this.maker = const Value.absent(),
  });
  GobosCompanion.insert({
    this.id = const Value.absent(),
    required String goboNumber,
    required int fixtureId,
    this.fixturePartId = const Value.absent(),
    this.size = const Value.absent(),
    this.maker = const Value.absent(),
  }) : goboNumber = Value(goboNumber),
       fixtureId = Value(fixtureId);
  static Insertable<Gobo> custom({
    Expression<int>? id,
    Expression<String>? goboNumber,
    Expression<int>? fixtureId,
    Expression<int>? fixturePartId,
    Expression<String>? size,
    Expression<String>? maker,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goboNumber != null) 'gobo_number': goboNumber,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (fixturePartId != null) 'fixture_part_id': fixturePartId,
      if (size != null) 'size': size,
      if (maker != null) 'maker': maker,
    });
  }

  GobosCompanion copyWith({
    Value<int>? id,
    Value<String>? goboNumber,
    Value<int>? fixtureId,
    Value<int?>? fixturePartId,
    Value<String?>? size,
    Value<String?>? maker,
  }) {
    return GobosCompanion(
      id: id ?? this.id,
      goboNumber: goboNumber ?? this.goboNumber,
      fixtureId: fixtureId ?? this.fixtureId,
      fixturePartId: fixturePartId ?? this.fixturePartId,
      size: size ?? this.size,
      maker: maker ?? this.maker,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goboNumber.present) {
      map['gobo_number'] = Variable<String>(goboNumber.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    if (fixturePartId.present) {
      map['fixture_part_id'] = Variable<int>(fixturePartId.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (maker.present) {
      map['maker'] = Variable<String>(maker.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GobosCompanion(')
          ..write('id: $id, ')
          ..write('goboNumber: $goboNumber, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('fixturePartId: $fixturePartId, ')
          ..write('size: $size, ')
          ..write('maker: $maker')
          ..write(')'))
        .toString();
  }
}

class $AccessoriesTable extends Accessories
    with TableInfo<$AccessoriesTable, Accessory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccessoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, fixtureId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accessories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Accessory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Accessory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Accessory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      )!,
    );
  }

  @override
  $AccessoriesTable createAlias(String alias) {
    return $AccessoriesTable(attachedDatabase, alias);
  }
}

class Accessory extends DataClass implements Insertable<Accessory> {
  final int id;
  final String name;
  final int fixtureId;
  const Accessory({
    required this.id,
    required this.name,
    required this.fixtureId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['fixture_id'] = Variable<int>(fixtureId);
    return map;
  }

  AccessoriesCompanion toCompanion(bool nullToAbsent) {
    return AccessoriesCompanion(
      id: Value(id),
      name: Value(name),
      fixtureId: Value(fixtureId),
    );
  }

  factory Accessory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Accessory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fixtureId: serializer.fromJson<int>(json['fixtureId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fixtureId': serializer.toJson<int>(fixtureId),
    };
  }

  Accessory copyWith({int? id, String? name, int? fixtureId}) => Accessory(
    id: id ?? this.id,
    name: name ?? this.name,
    fixtureId: fixtureId ?? this.fixtureId,
  );
  Accessory copyWithCompanion(AccessoriesCompanion data) {
    return Accessory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Accessory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fixtureId: $fixtureId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, fixtureId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Accessory &&
          other.id == this.id &&
          other.name == this.name &&
          other.fixtureId == this.fixtureId);
}

class AccessoriesCompanion extends UpdateCompanion<Accessory> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> fixtureId;
  const AccessoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fixtureId = const Value.absent(),
  });
  AccessoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int fixtureId,
  }) : name = Value(name),
       fixtureId = Value(fixtureId);
  static Insertable<Accessory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? fixtureId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fixtureId != null) 'fixture_id': fixtureId,
    });
  }

  AccessoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? fixtureId,
  }) {
    return AccessoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fixtureId: fixtureId ?? this.fixtureId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccessoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fixtureId: $fixtureId')
          ..write(')'))
        .toString();
  }
}

class $WorkNotesTable extends WorkNotes
    with TableInfo<$WorkNotesTable, WorkNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    body,
    userId,
    timestamp,
    fixtureId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $WorkNotesTable createAlias(String alias) {
    return $WorkNotesTable(attachedDatabase, alias);
  }
}

class WorkNote extends DataClass implements Insertable<WorkNote> {
  final int id;
  final String body;
  final String userId;
  final String timestamp;
  final int? fixtureId;
  final String? position;
  const WorkNote({
    required this.id,
    required this.body,
    required this.userId,
    required this.timestamp,
    this.fixtureId,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['body'] = Variable<String>(body);
    map['user_id'] = Variable<String>(userId);
    map['timestamp'] = Variable<String>(timestamp);
    if (!nullToAbsent || fixtureId != null) {
      map['fixture_id'] = Variable<int>(fixtureId);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    return map;
  }

  WorkNotesCompanion toCompanion(bool nullToAbsent) {
    return WorkNotesCompanion(
      id: Value(id),
      body: Value(body),
      userId: Value(userId),
      timestamp: Value(timestamp),
      fixtureId: fixtureId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixtureId),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory WorkNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkNote(
      id: serializer.fromJson<int>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      userId: serializer.fromJson<String>(json['userId']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      fixtureId: serializer.fromJson<int?>(json['fixtureId']),
      position: serializer.fromJson<String?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'body': serializer.toJson<String>(body),
      'userId': serializer.toJson<String>(userId),
      'timestamp': serializer.toJson<String>(timestamp),
      'fixtureId': serializer.toJson<int?>(fixtureId),
      'position': serializer.toJson<String?>(position),
    };
  }

  WorkNote copyWith({
    int? id,
    String? body,
    String? userId,
    String? timestamp,
    Value<int?> fixtureId = const Value.absent(),
    Value<String?> position = const Value.absent(),
  }) => WorkNote(
    id: id ?? this.id,
    body: body ?? this.body,
    userId: userId ?? this.userId,
    timestamp: timestamp ?? this.timestamp,
    fixtureId: fixtureId.present ? fixtureId.value : this.fixtureId,
    position: position.present ? position.value : this.position,
  );
  WorkNote copyWithCompanion(WorkNotesCompanion data) {
    return WorkNote(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkNote(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, body, userId, timestamp, fixtureId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkNote &&
          other.id == this.id &&
          other.body == this.body &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp &&
          other.fixtureId == this.fixtureId &&
          other.position == this.position);
}

class WorkNotesCompanion extends UpdateCompanion<WorkNote> {
  final Value<int> id;
  final Value<String> body;
  final Value<String> userId;
  final Value<String> timestamp;
  final Value<int?> fixtureId;
  final Value<String?> position;
  const WorkNotesCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.position = const Value.absent(),
  });
  WorkNotesCompanion.insert({
    this.id = const Value.absent(),
    required String body,
    required String userId,
    required String timestamp,
    this.fixtureId = const Value.absent(),
    this.position = const Value.absent(),
  }) : body = Value(body),
       userId = Value(userId),
       timestamp = Value(timestamp);
  static Insertable<WorkNote> custom({
    Expression<int>? id,
    Expression<String>? body,
    Expression<String>? userId,
    Expression<String>? timestamp,
    Expression<int>? fixtureId,
    Expression<String>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (position != null) 'position': position,
    });
  }

  WorkNotesCompanion copyWith({
    Value<int>? id,
    Value<String>? body,
    Value<String>? userId,
    Value<String>? timestamp,
    Value<int?>? fixtureId,
    Value<String?>? position,
  }) {
    return WorkNotesCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      fixtureId: fixtureId ?? this.fixtureId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkNotesCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceLogTable extends MaintenanceLog
    with TableInfo<$MaintenanceLogTable, MaintenanceLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<int> resolved = GeneratedColumn<int>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fixtureId,
    description,
    userId,
    timestamp,
    resolved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved'],
      )!,
    );
  }

  @override
  $MaintenanceLogTable createAlias(String alias) {
    return $MaintenanceLogTable(attachedDatabase, alias);
  }
}

class MaintenanceLogData extends DataClass
    implements Insertable<MaintenanceLogData> {
  final int id;
  final int fixtureId;
  final String description;
  final String userId;
  final String timestamp;
  final int resolved;
  const MaintenanceLogData({
    required this.id,
    required this.fixtureId,
    required this.description,
    required this.userId,
    required this.timestamp,
    required this.resolved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fixture_id'] = Variable<int>(fixtureId);
    map['description'] = Variable<String>(description);
    map['user_id'] = Variable<String>(userId);
    map['timestamp'] = Variable<String>(timestamp);
    map['resolved'] = Variable<int>(resolved);
    return map;
  }

  MaintenanceLogCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceLogCompanion(
      id: Value(id),
      fixtureId: Value(fixtureId),
      description: Value(description),
      userId: Value(userId),
      timestamp: Value(timestamp),
      resolved: Value(resolved),
    );
  }

  factory MaintenanceLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceLogData(
      id: serializer.fromJson<int>(json['id']),
      fixtureId: serializer.fromJson<int>(json['fixtureId']),
      description: serializer.fromJson<String>(json['description']),
      userId: serializer.fromJson<String>(json['userId']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      resolved: serializer.fromJson<int>(json['resolved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fixtureId': serializer.toJson<int>(fixtureId),
      'description': serializer.toJson<String>(description),
      'userId': serializer.toJson<String>(userId),
      'timestamp': serializer.toJson<String>(timestamp),
      'resolved': serializer.toJson<int>(resolved),
    };
  }

  MaintenanceLogData copyWith({
    int? id,
    int? fixtureId,
    String? description,
    String? userId,
    String? timestamp,
    int? resolved,
  }) => MaintenanceLogData(
    id: id ?? this.id,
    fixtureId: fixtureId ?? this.fixtureId,
    description: description ?? this.description,
    userId: userId ?? this.userId,
    timestamp: timestamp ?? this.timestamp,
    resolved: resolved ?? this.resolved,
  );
  MaintenanceLogData copyWithCompanion(MaintenanceLogCompanion data) {
    return MaintenanceLogData(
      id: data.id.present ? data.id.value : this.id,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      description: data.description.present
          ? data.description.value
          : this.description,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceLogData(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('resolved: $resolved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fixtureId, description, userId, timestamp, resolved);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceLogData &&
          other.id == this.id &&
          other.fixtureId == this.fixtureId &&
          other.description == this.description &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp &&
          other.resolved == this.resolved);
}

class MaintenanceLogCompanion extends UpdateCompanion<MaintenanceLogData> {
  final Value<int> id;
  final Value<int> fixtureId;
  final Value<String> description;
  final Value<String> userId;
  final Value<String> timestamp;
  final Value<int> resolved;
  const MaintenanceLogCompanion({
    this.id = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.description = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.resolved = const Value.absent(),
  });
  MaintenanceLogCompanion.insert({
    this.id = const Value.absent(),
    required int fixtureId,
    required String description,
    required String userId,
    required String timestamp,
    this.resolved = const Value.absent(),
  }) : fixtureId = Value(fixtureId),
       description = Value(description),
       userId = Value(userId),
       timestamp = Value(timestamp);
  static Insertable<MaintenanceLogData> custom({
    Expression<int>? id,
    Expression<int>? fixtureId,
    Expression<String>? description,
    Expression<String>? userId,
    Expression<String>? timestamp,
    Expression<int>? resolved,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (description != null) 'description': description,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
      if (resolved != null) 'resolved': resolved,
    });
  }

  MaintenanceLogCompanion copyWith({
    Value<int>? id,
    Value<int>? fixtureId,
    Value<String>? description,
    Value<String>? userId,
    Value<String>? timestamp,
    Value<int>? resolved,
  }) {
    return MaintenanceLogCompanion(
      id: id ?? this.id,
      fixtureId: fixtureId ?? this.fixtureId,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      resolved: resolved ?? this.resolved,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<int>(resolved.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceLogCompanion(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('description: $description, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('resolved: $resolved')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldsTable extends CustomFields
    with TableInfo<$CustomFieldsTable, CustomField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, dataType, displayOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomField> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomField(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $CustomFieldsTable createAlias(String alias) {
    return $CustomFieldsTable(attachedDatabase, alias);
  }
}

class CustomField extends DataClass implements Insertable<CustomField> {
  final int id;
  final String name;
  final String dataType;
  final int displayOrder;
  const CustomField({
    required this.id,
    required this.name,
    required this.dataType,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['data_type'] = Variable<String>(dataType);
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  CustomFieldsCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldsCompanion(
      id: Value(id),
      name: Value(name),
      dataType: Value(dataType),
      displayOrder: Value(displayOrder),
    );
  }

  factory CustomField.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomField(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dataType: serializer.fromJson<String>(json['dataType']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dataType': serializer.toJson<String>(dataType),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  CustomField copyWith({
    int? id,
    String? name,
    String? dataType,
    int? displayOrder,
  }) => CustomField(
    id: id ?? this.id,
    name: name ?? this.name,
    dataType: dataType ?? this.dataType,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  CustomField copyWithCompanion(CustomFieldsCompanion data) {
    return CustomField(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomField(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dataType: $dataType, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dataType, displayOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomField &&
          other.id == this.id &&
          other.name == this.name &&
          other.dataType == this.dataType &&
          other.displayOrder == this.displayOrder);
}

class CustomFieldsCompanion extends UpdateCompanion<CustomField> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> dataType;
  final Value<int> displayOrder;
  const CustomFieldsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dataType = const Value.absent(),
    this.displayOrder = const Value.absent(),
  });
  CustomFieldsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String dataType,
    this.displayOrder = const Value.absent(),
  }) : name = Value(name),
       dataType = Value(dataType);
  static Insertable<CustomField> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dataType,
    Expression<int>? displayOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dataType != null) 'data_type': dataType,
      if (displayOrder != null) 'display_order': displayOrder,
    });
  }

  CustomFieldsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? dataType,
    Value<int>? displayOrder,
  }) {
    return CustomFieldsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dataType: $dataType, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }
}

class $CustomFieldValuesTable extends CustomFieldValues
    with TableInfo<$CustomFieldValuesTable, CustomFieldValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFieldValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _customFieldIdMeta = const VerificationMeta(
    'customFieldId',
  );
  @override
  late final GeneratedColumn<int> customFieldId = GeneratedColumn<int>(
    'custom_field_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_fields (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fixtureId, customFieldId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFieldValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    if (data.containsKey('custom_field_id')) {
      context.handle(
        _customFieldIdMeta,
        customFieldId.isAcceptableOrUnknown(
          data['custom_field_id']!,
          _customFieldIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customFieldIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFieldValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFieldValue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      )!,
      customFieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_field_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $CustomFieldValuesTable createAlias(String alias) {
    return $CustomFieldValuesTable(attachedDatabase, alias);
  }
}

class CustomFieldValue extends DataClass
    implements Insertable<CustomFieldValue> {
  final int id;
  final int fixtureId;
  final int customFieldId;
  final String? value;
  const CustomFieldValue({
    required this.id,
    required this.fixtureId,
    required this.customFieldId,
    this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fixture_id'] = Variable<int>(fixtureId);
    map['custom_field_id'] = Variable<int>(customFieldId);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  CustomFieldValuesCompanion toCompanion(bool nullToAbsent) {
    return CustomFieldValuesCompanion(
      id: Value(id),
      fixtureId: Value(fixtureId),
      customFieldId: Value(customFieldId),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory CustomFieldValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFieldValue(
      id: serializer.fromJson<int>(json['id']),
      fixtureId: serializer.fromJson<int>(json['fixtureId']),
      customFieldId: serializer.fromJson<int>(json['customFieldId']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fixtureId': serializer.toJson<int>(fixtureId),
      'customFieldId': serializer.toJson<int>(customFieldId),
      'value': serializer.toJson<String?>(value),
    };
  }

  CustomFieldValue copyWith({
    int? id,
    int? fixtureId,
    int? customFieldId,
    Value<String?> value = const Value.absent(),
  }) => CustomFieldValue(
    id: id ?? this.id,
    fixtureId: fixtureId ?? this.fixtureId,
    customFieldId: customFieldId ?? this.customFieldId,
    value: value.present ? value.value : this.value,
  );
  CustomFieldValue copyWithCompanion(CustomFieldValuesCompanion data) {
    return CustomFieldValue(
      id: data.id.present ? data.id.value : this.id,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      customFieldId: data.customFieldId.present
          ? data.customFieldId.value
          : this.customFieldId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValue(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('customFieldId: $customFieldId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fixtureId, customFieldId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFieldValue &&
          other.id == this.id &&
          other.fixtureId == this.fixtureId &&
          other.customFieldId == this.customFieldId &&
          other.value == this.value);
}

class CustomFieldValuesCompanion extends UpdateCompanion<CustomFieldValue> {
  final Value<int> id;
  final Value<int> fixtureId;
  final Value<int> customFieldId;
  final Value<String?> value;
  const CustomFieldValuesCompanion({
    this.id = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.customFieldId = const Value.absent(),
    this.value = const Value.absent(),
  });
  CustomFieldValuesCompanion.insert({
    this.id = const Value.absent(),
    required int fixtureId,
    required int customFieldId,
    this.value = const Value.absent(),
  }) : fixtureId = Value(fixtureId),
       customFieldId = Value(customFieldId);
  static Insertable<CustomFieldValue> custom({
    Expression<int>? id,
    Expression<int>? fixtureId,
    Expression<int>? customFieldId,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (customFieldId != null) 'custom_field_id': customFieldId,
      if (value != null) 'value': value,
    });
  }

  CustomFieldValuesCompanion copyWith({
    Value<int>? id,
    Value<int>? fixtureId,
    Value<int>? customFieldId,
    Value<String?>? value,
  }) {
    return CustomFieldValuesCompanion(
      id: id ?? this.id,
      fixtureId: fixtureId ?? this.fixtureId,
      customFieldId: customFieldId ?? this.customFieldId,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    if (customFieldId.present) {
      map['custom_field_id'] = Variable<int>(customFieldId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFieldValuesCompanion(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('customFieldId: $customFieldId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $ReportsTable extends Reports with TableInfo<$ReportsTable, Report> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateJsonMeta = const VerificationMeta(
    'templateJson',
  );
  @override
  late final GeneratedColumn<String> templateJson = GeneratedColumn<String>(
    'template_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<int> isSystem = GeneratedColumn<int>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, templateJson, isSystem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Report> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('template_json')) {
      context.handle(
        _templateJsonMeta,
        templateJson.isAcceptableOrUnknown(
          data['template_json']!,
          _templateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateJsonMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Report map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Report(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      templateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_json'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_system'],
      )!,
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
  }
}

class Report extends DataClass implements Insertable<Report> {
  final int id;
  final String name;
  final String templateJson;
  final int isSystem;
  const Report({
    required this.id,
    required this.name,
    required this.templateJson,
    required this.isSystem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['template_json'] = Variable<String>(templateJson);
    map['is_system'] = Variable<int>(isSystem);
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      name: Value(name),
      templateJson: Value(templateJson),
      isSystem: Value(isSystem),
    );
  }

  factory Report.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Report(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      templateJson: serializer.fromJson<String>(json['templateJson']),
      isSystem: serializer.fromJson<int>(json['isSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'templateJson': serializer.toJson<String>(templateJson),
      'isSystem': serializer.toJson<int>(isSystem),
    };
  }

  Report copyWith({
    int? id,
    String? name,
    String? templateJson,
    int? isSystem,
  }) => Report(
    id: id ?? this.id,
    name: name ?? this.name,
    templateJson: templateJson ?? this.templateJson,
    isSystem: isSystem ?? this.isSystem,
  );
  Report copyWithCompanion(ReportsCompanion data) {
    return Report(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      templateJson: data.templateJson.present
          ? data.templateJson.value
          : this.templateJson,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Report(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('templateJson: $templateJson, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, templateJson, isSystem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Report &&
          other.id == this.id &&
          other.name == this.name &&
          other.templateJson == this.templateJson &&
          other.isSystem == this.isSystem);
}

class ReportsCompanion extends UpdateCompanion<Report> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> templateJson;
  final Value<int> isSystem;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.templateJson = const Value.absent(),
    this.isSystem = const Value.absent(),
  });
  ReportsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String templateJson,
    this.isSystem = const Value.absent(),
  }) : name = Value(name),
       templateJson = Value(templateJson);
  static Insertable<Report> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? templateJson,
    Expression<int>? isSystem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (templateJson != null) 'template_json': templateJson,
      if (isSystem != null) 'is_system': isSystem,
    });
  }

  ReportsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? templateJson,
    Value<int>? isSystem,
  }) {
    return ReportsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      templateJson: templateJson ?? this.templateJson,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (templateJson.present) {
      map['template_json'] = Variable<String>(templateJson.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<int>(isSystem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('templateJson: $templateJson, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }
}

class $CommitsTable extends Commits with TableInfo<$CommitsTable, Commit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, timestamp, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Commit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Commit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Commit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CommitsTable createAlias(String alias) {
    return $CommitsTable(attachedDatabase, alias);
  }
}

class Commit extends DataClass implements Insertable<Commit> {
  final int id;
  final String userId;
  final String timestamp;
  final String? notes;
  const Commit({
    required this.id,
    required this.userId,
    required this.timestamp,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['timestamp'] = Variable<String>(timestamp);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CommitsCompanion toCompanion(bool nullToAbsent) {
    return CommitsCompanion(
      id: Value(id),
      userId: Value(userId),
      timestamp: Value(timestamp),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Commit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Commit(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'timestamp': serializer.toJson<String>(timestamp),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Commit copyWith({
    int? id,
    String? userId,
    String? timestamp,
    Value<String?> notes = const Value.absent(),
  }) => Commit(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    timestamp: timestamp ?? this.timestamp,
    notes: notes.present ? notes.value : this.notes,
  );
  Commit copyWithCompanion(CommitsCompanion data) {
    return Commit(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Commit(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, timestamp, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Commit &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp &&
          other.notes == this.notes);
}

class CommitsCompanion extends UpdateCompanion<Commit> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> timestamp;
  final Value<String?> notes;
  const CommitsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CommitsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String timestamp,
    this.notes = const Value.absent(),
  }) : userId = Value(userId),
       timestamp = Value(timestamp);
  static Insertable<Commit> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? timestamp,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
      if (notes != null) 'notes': notes,
    });
  }

  CommitsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? timestamp,
    Value<String?>? notes,
  }) {
    return CommitsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RevisionsTable extends Revisions
    with TableInfo<$RevisionsTable, Revision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldNameMeta = const VerificationMeta(
    'fieldName',
  );
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
    'field_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _commitIdMeta = const VerificationMeta(
    'commitId',
  );
  @override
  late final GeneratedColumn<int> commitId = GeneratedColumn<int>(
    'commit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES commits (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    targetTable,
    targetId,
    fieldName,
    oldValue,
    newValue,
    batchId,
    userId,
    timestamp,
    status,
    commitId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Revision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    }
    if (data.containsKey('field_name')) {
      context.handle(
        _fieldNameMeta,
        fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta),
      );
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('commit_id')) {
      context.handle(
        _commitIdMeta,
        commitId.isAcceptableOrUnknown(data['commit_id']!, _commitIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Revision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Revision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      ),
      fieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_name'],
      ),
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      commitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commit_id'],
      ),
    );
  }

  @override
  $RevisionsTable createAlias(String alias) {
    return $RevisionsTable(attachedDatabase, alias);
  }
}

class Revision extends DataClass implements Insertable<Revision> {
  final int id;
  final String operation;
  final String targetTable;
  final int? targetId;
  final String? fieldName;
  final String? oldValue;
  final String? newValue;
  final String? batchId;
  final String userId;
  final String timestamp;
  final String status;
  final int? commitId;
  const Revision({
    required this.id,
    required this.operation,
    required this.targetTable,
    this.targetId,
    this.fieldName,
    this.oldValue,
    this.newValue,
    this.batchId,
    required this.userId,
    required this.timestamp,
    required this.status,
    this.commitId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['target_table'] = Variable<String>(targetTable);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<int>(targetId);
    }
    if (!nullToAbsent || fieldName != null) {
      map['field_name'] = Variable<String>(fieldName);
    }
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    map['user_id'] = Variable<String>(userId);
    map['timestamp'] = Variable<String>(timestamp);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || commitId != null) {
      map['commit_id'] = Variable<int>(commitId);
    }
    return map;
  }

  RevisionsCompanion toCompanion(bool nullToAbsent) {
    return RevisionsCompanion(
      id: Value(id),
      operation: Value(operation),
      targetTable: Value(targetTable),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      fieldName: fieldName == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldName),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      userId: Value(userId),
      timestamp: Value(timestamp),
      status: Value(status),
      commitId: commitId == null && nullToAbsent
          ? const Value.absent()
          : Value(commitId),
    );
  }

  factory Revision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Revision(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      targetId: serializer.fromJson<int?>(json['targetId']),
      fieldName: serializer.fromJson<String?>(json['fieldName']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      userId: serializer.fromJson<String>(json['userId']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      status: serializer.fromJson<String>(json['status']),
      commitId: serializer.fromJson<int?>(json['commitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'targetTable': serializer.toJson<String>(targetTable),
      'targetId': serializer.toJson<int?>(targetId),
      'fieldName': serializer.toJson<String?>(fieldName),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'batchId': serializer.toJson<String?>(batchId),
      'userId': serializer.toJson<String>(userId),
      'timestamp': serializer.toJson<String>(timestamp),
      'status': serializer.toJson<String>(status),
      'commitId': serializer.toJson<int?>(commitId),
    };
  }

  Revision copyWith({
    int? id,
    String? operation,
    String? targetTable,
    Value<int?> targetId = const Value.absent(),
    Value<String?> fieldName = const Value.absent(),
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    Value<String?> batchId = const Value.absent(),
    String? userId,
    String? timestamp,
    String? status,
    Value<int?> commitId = const Value.absent(),
  }) => Revision(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    targetTable: targetTable ?? this.targetTable,
    targetId: targetId.present ? targetId.value : this.targetId,
    fieldName: fieldName.present ? fieldName.value : this.fieldName,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    batchId: batchId.present ? batchId.value : this.batchId,
    userId: userId ?? this.userId,
    timestamp: timestamp ?? this.timestamp,
    status: status ?? this.status,
    commitId: commitId.present ? commitId.value : this.commitId,
  );
  Revision copyWithCompanion(RevisionsCompanion data) {
    return Revision(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      status: data.status.present ? data.status.value : this.status,
      commitId: data.commitId.present ? data.commitId.value : this.commitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Revision(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('targetTable: $targetTable, ')
          ..write('targetId: $targetId, ')
          ..write('fieldName: $fieldName, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('batchId: $batchId, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('commitId: $commitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operation,
    targetTable,
    targetId,
    fieldName,
    oldValue,
    newValue,
    batchId,
    userId,
    timestamp,
    status,
    commitId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Revision &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.targetTable == this.targetTable &&
          other.targetId == this.targetId &&
          other.fieldName == this.fieldName &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.batchId == this.batchId &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp &&
          other.status == this.status &&
          other.commitId == this.commitId);
}

class RevisionsCompanion extends UpdateCompanion<Revision> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> targetTable;
  final Value<int?> targetId;
  final Value<String?> fieldName;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String?> batchId;
  final Value<String> userId;
  final Value<String> timestamp;
  final Value<String> status;
  final Value<int?> commitId;
  const RevisionsCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.targetId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.batchId = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
    this.commitId = const Value.absent(),
  });
  RevisionsCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String targetTable,
    this.targetId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.batchId = const Value.absent(),
    required String userId,
    required String timestamp,
    this.status = const Value.absent(),
    this.commitId = const Value.absent(),
  }) : operation = Value(operation),
       targetTable = Value(targetTable),
       userId = Value(userId),
       timestamp = Value(timestamp);
  static Insertable<Revision> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? targetTable,
    Expression<int>? targetId,
    Expression<String>? fieldName,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? batchId,
    Expression<String>? userId,
    Expression<String>? timestamp,
    Expression<String>? status,
    Expression<int>? commitId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (targetTable != null) 'target_table': targetTable,
      if (targetId != null) 'target_id': targetId,
      if (fieldName != null) 'field_name': fieldName,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (batchId != null) 'batch_id': batchId,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
      if (status != null) 'status': status,
      if (commitId != null) 'commit_id': commitId,
    });
  }

  RevisionsCompanion copyWith({
    Value<int>? id,
    Value<String>? operation,
    Value<String>? targetTable,
    Value<int?>? targetId,
    Value<String?>? fieldName,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<String?>? batchId,
    Value<String>? userId,
    Value<String>? timestamp,
    Value<String>? status,
    Value<int?>? commitId,
  }) {
    return RevisionsCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      targetTable: targetTable ?? this.targetTable,
      targetId: targetId ?? this.targetId,
      fieldName: fieldName ?? this.fieldName,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      batchId: batchId ?? this.batchId,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      commitId: commitId ?? this.commitId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (commitId.present) {
      map['commit_id'] = Variable<int>(commitId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevisionsCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('targetTable: $targetTable, ')
          ..write('targetId: $targetId, ')
          ..write('fieldName: $fieldName, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('batchId: $batchId, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('commitId: $commitId')
          ..write(')'))
        .toString();
  }
}

class $PositionGroupsTable extends PositionGroups
    with TableInfo<$PositionGroupsTable, PositionGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PositionGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'position_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<PositionGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PositionGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PositionGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $PositionGroupsTable createAlias(String alias) {
    return $PositionGroupsTable(attachedDatabase, alias);
  }
}

class PositionGroup extends DataClass implements Insertable<PositionGroup> {
  final int id;
  final String name;
  final int sortOrder;
  final String? color;
  const PositionGroup({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  PositionGroupsCompanion toCompanion(bool nullToAbsent) {
    return PositionGroupsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory PositionGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PositionGroup(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'color': serializer.toJson<String?>(color),
    };
  }

  PositionGroup copyWith({
    int? id,
    String? name,
    int? sortOrder,
    Value<String?> color = const Value.absent(),
  }) => PositionGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    color: color.present ? color.value : this.color,
  );
  PositionGroup copyWithCompanion(PositionGroupsCompanion data) {
    return PositionGroup(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PositionGroup(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PositionGroup &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.color == this.color);
}

class PositionGroupsCompanion extends UpdateCompanion<PositionGroup> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String?> color;
  const PositionGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
  });
  PositionGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PositionGroup> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (color != null) 'color': color,
    });
  }

  PositionGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<String?>? color,
  }) {
    return PositionGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PositionGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $RoleContactsTable extends RoleContacts
    with TableInfo<$RoleContactsTable, RoleContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoleContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _roleKeyMeta = const VerificationMeta(
    'roleKey',
  );
  @override
  late final GeneratedColumn<String> roleKey = GeneratedColumn<String>(
    'role_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mailingAddressMeta = const VerificationMeta(
    'mailingAddress',
  );
  @override
  late final GeneratedColumn<String> mailingAddress = GeneratedColumn<String>(
    'mailing_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paperTekUserIdMeta = const VerificationMeta(
    'paperTekUserId',
  );
  @override
  late final GeneratedColumn<String> paperTekUserId = GeneratedColumn<String>(
    'paper_tek_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roleKey,
    email,
    phone,
    mailingAddress,
    paperTekUserId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'role_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoleContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role_key')) {
      context.handle(
        _roleKeyMeta,
        roleKey.isAcceptableOrUnknown(data['role_key']!, _roleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_roleKeyMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('mailing_address')) {
      context.handle(
        _mailingAddressMeta,
        mailingAddress.isAcceptableOrUnknown(
          data['mailing_address']!,
          _mailingAddressMeta,
        ),
      );
    }
    if (data.containsKey('paper_tek_user_id')) {
      context.handle(
        _paperTekUserIdMeta,
        paperTekUserId.isAcceptableOrUnknown(
          data['paper_tek_user_id']!,
          _paperTekUserIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoleContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoleContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_key'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      mailingAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mailing_address'],
      ),
      paperTekUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paper_tek_user_id'],
      ),
    );
  }

  @override
  $RoleContactsTable createAlias(String alias) {
    return $RoleContactsTable(attachedDatabase, alias);
  }
}

class RoleContact extends DataClass implements Insertable<RoleContact> {
  final int id;
  final String roleKey;
  final String? email;
  final String? phone;
  final String? mailingAddress;
  final String? paperTekUserId;
  const RoleContact({
    required this.id,
    required this.roleKey,
    this.email,
    this.phone,
    this.mailingAddress,
    this.paperTekUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role_key'] = Variable<String>(roleKey);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || mailingAddress != null) {
      map['mailing_address'] = Variable<String>(mailingAddress);
    }
    if (!nullToAbsent || paperTekUserId != null) {
      map['paper_tek_user_id'] = Variable<String>(paperTekUserId);
    }
    return map;
  }

  RoleContactsCompanion toCompanion(bool nullToAbsent) {
    return RoleContactsCompanion(
      id: Value(id),
      roleKey: Value(roleKey),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      mailingAddress: mailingAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(mailingAddress),
      paperTekUserId: paperTekUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(paperTekUserId),
    );
  }

  factory RoleContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoleContact(
      id: serializer.fromJson<int>(json['id']),
      roleKey: serializer.fromJson<String>(json['roleKey']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      mailingAddress: serializer.fromJson<String?>(json['mailingAddress']),
      paperTekUserId: serializer.fromJson<String?>(json['paperTekUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roleKey': serializer.toJson<String>(roleKey),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'mailingAddress': serializer.toJson<String?>(mailingAddress),
      'paperTekUserId': serializer.toJson<String?>(paperTekUserId),
    };
  }

  RoleContact copyWith({
    int? id,
    String? roleKey,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> mailingAddress = const Value.absent(),
    Value<String?> paperTekUserId = const Value.absent(),
  }) => RoleContact(
    id: id ?? this.id,
    roleKey: roleKey ?? this.roleKey,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    mailingAddress: mailingAddress.present
        ? mailingAddress.value
        : this.mailingAddress,
    paperTekUserId: paperTekUserId.present
        ? paperTekUserId.value
        : this.paperTekUserId,
  );
  RoleContact copyWithCompanion(RoleContactsCompanion data) {
    return RoleContact(
      id: data.id.present ? data.id.value : this.id,
      roleKey: data.roleKey.present ? data.roleKey.value : this.roleKey,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      mailingAddress: data.mailingAddress.present
          ? data.mailingAddress.value
          : this.mailingAddress,
      paperTekUserId: data.paperTekUserId.present
          ? data.paperTekUserId.value
          : this.paperTekUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoleContact(')
          ..write('id: $id, ')
          ..write('roleKey: $roleKey, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('mailingAddress: $mailingAddress, ')
          ..write('paperTekUserId: $paperTekUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, roleKey, email, phone, mailingAddress, paperTekUserId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoleContact &&
          other.id == this.id &&
          other.roleKey == this.roleKey &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.mailingAddress == this.mailingAddress &&
          other.paperTekUserId == this.paperTekUserId);
}

class RoleContactsCompanion extends UpdateCompanion<RoleContact> {
  final Value<int> id;
  final Value<String> roleKey;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> mailingAddress;
  final Value<String?> paperTekUserId;
  const RoleContactsCompanion({
    this.id = const Value.absent(),
    this.roleKey = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.mailingAddress = const Value.absent(),
    this.paperTekUserId = const Value.absent(),
  });
  RoleContactsCompanion.insert({
    this.id = const Value.absent(),
    required String roleKey,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.mailingAddress = const Value.absent(),
    this.paperTekUserId = const Value.absent(),
  }) : roleKey = Value(roleKey);
  static Insertable<RoleContact> custom({
    Expression<int>? id,
    Expression<String>? roleKey,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? mailingAddress,
    Expression<String>? paperTekUserId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roleKey != null) 'role_key': roleKey,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (mailingAddress != null) 'mailing_address': mailingAddress,
      if (paperTekUserId != null) 'paper_tek_user_id': paperTekUserId,
    });
  }

  RoleContactsCompanion copyWith({
    Value<int>? id,
    Value<String>? roleKey,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? mailingAddress,
    Value<String?>? paperTekUserId,
  }) {
    return RoleContactsCompanion(
      id: id ?? this.id,
      roleKey: roleKey ?? this.roleKey,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mailingAddress: mailingAddress ?? this.mailingAddress,
      paperTekUserId: paperTekUserId ?? this.paperTekUserId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roleKey.present) {
      map['role_key'] = Variable<String>(roleKey.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (mailingAddress.present) {
      map['mailing_address'] = Variable<String>(mailingAddress.value);
    }
    if (paperTekUserId.present) {
      map['paper_tek_user_id'] = Variable<String>(paperTekUserId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoleContactsCompanion(')
          ..write('id: $id, ')
          ..write('roleKey: $roleKey, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('mailingAddress: $mailingAddress, ')
          ..write('paperTekUserId: $paperTekUserId')
          ..write(')'))
        .toString();
  }
}

class $SpreadsheetViewPresetsTable extends SpreadsheetViewPresets
    with TableInfo<$SpreadsheetViewPresetsTable, SpreadsheetViewPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpreadsheetViewPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<int> isSystem = GeneratedColumn<int>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetJsonMeta = const VerificationMeta(
    'presetJson',
  );
  @override
  late final GeneratedColumn<String> presetJson = GeneratedColumn<String>(
    'preset_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isSystem,
    createdAt,
    updatedAt,
    presetJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spreadsheet_view_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpreadsheetViewPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('preset_json')) {
      context.handle(
        _presetJsonMeta,
        presetJson.isAcceptableOrUnknown(data['preset_json']!, _presetJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_presetJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpreadsheetViewPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpreadsheetViewPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      presetJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_json'],
      )!,
    );
  }

  @override
  $SpreadsheetViewPresetsTable createAlias(String alias) {
    return $SpreadsheetViewPresetsTable(attachedDatabase, alias);
  }
}

class SpreadsheetViewPreset extends DataClass
    implements Insertable<SpreadsheetViewPreset> {
  final int id;
  final String name;
  final int isSystem;
  final String createdAt;
  final String updatedAt;
  final String presetJson;
  const SpreadsheetViewPreset({
    required this.id,
    required this.name,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
    required this.presetJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_system'] = Variable<int>(isSystem);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['preset_json'] = Variable<String>(presetJson);
    return map;
  }

  SpreadsheetViewPresetsCompanion toCompanion(bool nullToAbsent) {
    return SpreadsheetViewPresetsCompanion(
      id: Value(id),
      name: Value(name),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      presetJson: Value(presetJson),
    );
  }

  factory SpreadsheetViewPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpreadsheetViewPreset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isSystem: serializer.fromJson<int>(json['isSystem']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      presetJson: serializer.fromJson<String>(json['presetJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isSystem': serializer.toJson<int>(isSystem),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'presetJson': serializer.toJson<String>(presetJson),
    };
  }

  SpreadsheetViewPreset copyWith({
    int? id,
    String? name,
    int? isSystem,
    String? createdAt,
    String? updatedAt,
    String? presetJson,
  }) => SpreadsheetViewPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    presetJson: presetJson ?? this.presetJson,
  );
  SpreadsheetViewPreset copyWithCompanion(
    SpreadsheetViewPresetsCompanion data,
  ) {
    return SpreadsheetViewPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      presetJson: data.presetJson.present
          ? data.presetJson.value
          : this.presetJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpreadsheetViewPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('presetJson: $presetJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isSystem, createdAt, updatedAt, presetJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpreadsheetViewPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.presetJson == this.presetJson);
}

class SpreadsheetViewPresetsCompanion
    extends UpdateCompanion<SpreadsheetViewPreset> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> isSystem;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> presetJson;
  const SpreadsheetViewPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.presetJson = const Value.absent(),
  });
  SpreadsheetViewPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isSystem = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    required String presetJson,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       presetJson = Value(presetJson);
  static Insertable<SpreadsheetViewPreset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? isSystem,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? presetJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (presetJson != null) 'preset_json': presetJson,
    });
  }

  SpreadsheetViewPresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? isSystem,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? presetJson,
  }) {
    return SpreadsheetViewPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      presetJson: presetJson ?? this.presetJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<int>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (presetJson.present) {
      map['preset_json'] = Variable<String>(presetJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpreadsheetViewPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('presetJson: $presetJson')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<int> completed = GeneratedColumn<int>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedByMeta = const VerificationMeta(
    'completedBy',
  );
  @override
  late final GeneratedColumn<String> completedBy = GeneratedColumn<String>(
    'completed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevatedMeta = const VerificationMeta(
    'elevated',
  );
  @override
  late final GeneratedColumn<int> elevated = GeneratedColumn<int>(
    'elevated',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fixtureTypeIdMeta = const VerificationMeta(
    'fixtureTypeId',
  );
  @override
  late final GeneratedColumn<int> fixtureTypeId = GeneratedColumn<int>(
    'fixture_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixture_types (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    body,
    createdBy,
    createdAt,
    completed,
    completedAt,
    completedBy,
    elevated,
    fixtureTypeId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_by')) {
      context.handle(
        _completedByMeta,
        completedBy.isAcceptableOrUnknown(
          data['completed_by']!,
          _completedByMeta,
        ),
      );
    }
    if (data.containsKey('elevated')) {
      context.handle(
        _elevatedMeta,
        elevated.isAcceptableOrUnknown(data['elevated']!, _elevatedMeta),
      );
    }
    if (data.containsKey('fixture_type_id')) {
      context.handle(
        _fixtureTypeIdMeta,
        fixtureTypeId.isAcceptableOrUnknown(
          data['fixture_type_id']!,
          _fixtureTypeIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      ),
      completedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_by'],
      ),
      elevated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elevated'],
      )!,
      fixtureTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_type_id'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String type;
  final String body;
  final String createdBy;
  final String createdAt;
  final int completed;
  final String? completedAt;
  final String? completedBy;
  final int elevated;
  final int? fixtureTypeId;
  const Note({
    required this.id,
    required this.type,
    required this.body,
    required this.createdBy,
    required this.createdAt,
    required this.completed,
    this.completedAt,
    this.completedBy,
    required this.elevated,
    this.fixtureTypeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['body'] = Variable<String>(body);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<String>(createdAt);
    map['completed'] = Variable<int>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    if (!nullToAbsent || completedBy != null) {
      map['completed_by'] = Variable<String>(completedBy);
    }
    map['elevated'] = Variable<int>(elevated);
    if (!nullToAbsent || fixtureTypeId != null) {
      map['fixture_type_id'] = Variable<int>(fixtureTypeId);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      type: Value(type),
      body: Value(body),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completedBy: completedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(completedBy),
      elevated: Value(elevated),
      fixtureTypeId: fixtureTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixtureTypeId),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      body: serializer.fromJson<String>(json['body']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      completed: serializer.fromJson<int>(json['completed']),
      completedAt: serializer.fromJson<String?>(json['completedAt']),
      completedBy: serializer.fromJson<String?>(json['completedBy']),
      elevated: serializer.fromJson<int>(json['elevated']),
      fixtureTypeId: serializer.fromJson<int?>(json['fixtureTypeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'body': serializer.toJson<String>(body),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<String>(createdAt),
      'completed': serializer.toJson<int>(completed),
      'completedAt': serializer.toJson<String?>(completedAt),
      'completedBy': serializer.toJson<String?>(completedBy),
      'elevated': serializer.toJson<int>(elevated),
      'fixtureTypeId': serializer.toJson<int?>(fixtureTypeId),
    };
  }

  Note copyWith({
    int? id,
    String? type,
    String? body,
    String? createdBy,
    String? createdAt,
    int? completed,
    Value<String?> completedAt = const Value.absent(),
    Value<String?> completedBy = const Value.absent(),
    int? elevated,
    Value<int?> fixtureTypeId = const Value.absent(),
  }) => Note(
    id: id ?? this.id,
    type: type ?? this.type,
    body: body ?? this.body,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completedBy: completedBy.present ? completedBy.value : this.completedBy,
    elevated: elevated ?? this.elevated,
    fixtureTypeId: fixtureTypeId.present
        ? fixtureTypeId.value
        : this.fixtureTypeId,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      body: data.body.present ? data.body.value : this.body,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completedBy: data.completedBy.present
          ? data.completedBy.value
          : this.completedBy,
      elevated: data.elevated.present ? data.elevated.value : this.elevated,
      fixtureTypeId: data.fixtureTypeId.present
          ? data.fixtureTypeId.value
          : this.fixtureTypeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedBy: $completedBy, ')
          ..write('elevated: $elevated, ')
          ..write('fixtureTypeId: $fixtureTypeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    body,
    createdBy,
    createdAt,
    completed,
    completedAt,
    completedBy,
    elevated,
    fixtureTypeId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.type == this.type &&
          other.body == this.body &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.completedBy == this.completedBy &&
          other.elevated == this.elevated &&
          other.fixtureTypeId == this.fixtureTypeId);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> body;
  final Value<String> createdBy;
  final Value<String> createdAt;
  final Value<int> completed;
  final Value<String?> completedAt;
  final Value<String?> completedBy;
  final Value<int> elevated;
  final Value<int?> fixtureTypeId;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedBy = const Value.absent(),
    this.elevated = const Value.absent(),
    this.fixtureTypeId = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String body,
    required String createdBy,
    required String createdAt,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedBy = const Value.absent(),
    this.elevated = const Value.absent(),
    this.fixtureTypeId = const Value.absent(),
  }) : type = Value(type),
       body = Value(body),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? body,
    Expression<String>? createdBy,
    Expression<String>? createdAt,
    Expression<int>? completed,
    Expression<String>? completedAt,
    Expression<String>? completedBy,
    Expression<int>? elevated,
    Expression<int>? fixtureTypeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (body != null) 'body': body,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (completedBy != null) 'completed_by': completedBy,
      if (elevated != null) 'elevated': elevated,
      if (fixtureTypeId != null) 'fixture_type_id': fixtureTypeId,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? body,
    Value<String>? createdBy,
    Value<String>? createdAt,
    Value<int>? completed,
    Value<String?>? completedAt,
    Value<String?>? completedBy,
    Value<int>? elevated,
    Value<int?>? fixtureTypeId,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      body: body ?? this.body,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      elevated: elevated ?? this.elevated,
      fixtureTypeId: fixtureTypeId ?? this.fixtureTypeId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<int>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    if (completedBy.present) {
      map['completed_by'] = Variable<String>(completedBy.value);
    }
    if (elevated.present) {
      map['elevated'] = Variable<int>(elevated.value);
    }
    if (fixtureTypeId.present) {
      map['fixture_type_id'] = Variable<int>(fixtureTypeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedBy: $completedBy, ')
          ..write('elevated: $elevated, ')
          ..write('fixtureTypeId: $fixtureTypeId')
          ..write(')'))
        .toString();
  }
}

class $NoteActionsTable extends NoteActions
    with TableInfo<$NoteActionsTable, NoteAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, noteId, body, userId, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteAction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteAction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $NoteActionsTable createAlias(String alias) {
    return $NoteActionsTable(attachedDatabase, alias);
  }
}

class NoteAction extends DataClass implements Insertable<NoteAction> {
  final int id;
  final int noteId;
  final String body;
  final String userId;
  final String timestamp;
  const NoteAction({
    required this.id,
    required this.noteId,
    required this.body,
    required this.userId,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note_id'] = Variable<int>(noteId);
    map['body'] = Variable<String>(body);
    map['user_id'] = Variable<String>(userId);
    map['timestamp'] = Variable<String>(timestamp);
    return map;
  }

  NoteActionsCompanion toCompanion(bool nullToAbsent) {
    return NoteActionsCompanion(
      id: Value(id),
      noteId: Value(noteId),
      body: Value(body),
      userId: Value(userId),
      timestamp: Value(timestamp),
    );
  }

  factory NoteAction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteAction(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<int>(json['noteId']),
      body: serializer.fromJson<String>(json['body']),
      userId: serializer.fromJson<String>(json['userId']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<int>(noteId),
      'body': serializer.toJson<String>(body),
      'userId': serializer.toJson<String>(userId),
      'timestamp': serializer.toJson<String>(timestamp),
    };
  }

  NoteAction copyWith({
    int? id,
    int? noteId,
    String? body,
    String? userId,
    String? timestamp,
  }) => NoteAction(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    body: body ?? this.body,
    userId: userId ?? this.userId,
    timestamp: timestamp ?? this.timestamp,
  );
  NoteAction copyWithCompanion(NoteActionsCompanion data) {
    return NoteAction(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      body: data.body.present ? data.body.value : this.body,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteAction(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('body: $body, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noteId, body, userId, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteAction &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.body == this.body &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp);
}

class NoteActionsCompanion extends UpdateCompanion<NoteAction> {
  final Value<int> id;
  final Value<int> noteId;
  final Value<String> body;
  final Value<String> userId;
  final Value<String> timestamp;
  const NoteActionsCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.body = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  NoteActionsCompanion.insert({
    this.id = const Value.absent(),
    required int noteId,
    required String body,
    required String userId,
    required String timestamp,
  }) : noteId = Value(noteId),
       body = Value(body),
       userId = Value(userId),
       timestamp = Value(timestamp);
  static Insertable<NoteAction> custom({
    Expression<int>? id,
    Expression<int>? noteId,
    Expression<String>? body,
    Expression<String>? userId,
    Expression<String>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (body != null) 'body': body,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  NoteActionsCompanion copyWith({
    Value<int>? id,
    Value<int>? noteId,
    Value<String>? body,
    Value<String>? userId,
    Value<String>? timestamp,
  }) {
    return NoteActionsCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteActionsCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('body: $body, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $NoteFixturesTable extends NoteFixtures
    with TableInfo<$NoteFixturesTable, NoteFixture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteFixturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<int> fixtureId = GeneratedColumn<int>(
    'fixture_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fixtures (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, noteId, fixtureId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_fixtures';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteFixture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteFixture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteFixture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixture_id'],
      )!,
    );
  }

  @override
  $NoteFixturesTable createAlias(String alias) {
    return $NoteFixturesTable(attachedDatabase, alias);
  }
}

class NoteFixture extends DataClass implements Insertable<NoteFixture> {
  final int id;
  final int noteId;
  final int fixtureId;
  const NoteFixture({
    required this.id,
    required this.noteId,
    required this.fixtureId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note_id'] = Variable<int>(noteId);
    map['fixture_id'] = Variable<int>(fixtureId);
    return map;
  }

  NoteFixturesCompanion toCompanion(bool nullToAbsent) {
    return NoteFixturesCompanion(
      id: Value(id),
      noteId: Value(noteId),
      fixtureId: Value(fixtureId),
    );
  }

  factory NoteFixture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteFixture(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<int>(json['noteId']),
      fixtureId: serializer.fromJson<int>(json['fixtureId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<int>(noteId),
      'fixtureId': serializer.toJson<int>(fixtureId),
    };
  }

  NoteFixture copyWith({int? id, int? noteId, int? fixtureId}) => NoteFixture(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    fixtureId: fixtureId ?? this.fixtureId,
  );
  NoteFixture copyWithCompanion(NoteFixturesCompanion data) {
    return NoteFixture(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteFixture(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('fixtureId: $fixtureId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noteId, fixtureId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteFixture &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.fixtureId == this.fixtureId);
}

class NoteFixturesCompanion extends UpdateCompanion<NoteFixture> {
  final Value<int> id;
  final Value<int> noteId;
  final Value<int> fixtureId;
  const NoteFixturesCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.fixtureId = const Value.absent(),
  });
  NoteFixturesCompanion.insert({
    this.id = const Value.absent(),
    required int noteId,
    required int fixtureId,
  }) : noteId = Value(noteId),
       fixtureId = Value(fixtureId);
  static Insertable<NoteFixture> custom({
    Expression<int>? id,
    Expression<int>? noteId,
    Expression<int>? fixtureId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (fixtureId != null) 'fixture_id': fixtureId,
    });
  }

  NoteFixturesCompanion copyWith({
    Value<int>? id,
    Value<int>? noteId,
    Value<int>? fixtureId,
  }) {
    return NoteFixturesCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      fixtureId: fixtureId ?? this.fixtureId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<int>(fixtureId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteFixturesCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('fixtureId: $fixtureId')
          ..write(')'))
        .toString();
  }
}

class $NotePositionsTable extends NotePositions
    with TableInfo<$NotePositionsTable, NotePosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotePositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionNameMeta = const VerificationMeta(
    'positionName',
  );
  @override
  late final GeneratedColumn<String> positionName = GeneratedColumn<String>(
    'position_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, noteId, positionName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotePosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('position_name')) {
      context.handle(
        _positionNameMeta,
        positionName.isAcceptableOrUnknown(
          data['position_name']!,
          _positionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotePosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotePosition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      positionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_name'],
      )!,
    );
  }

  @override
  $NotePositionsTable createAlias(String alias) {
    return $NotePositionsTable(attachedDatabase, alias);
  }
}

class NotePosition extends DataClass implements Insertable<NotePosition> {
  final int id;
  final int noteId;
  final String positionName;
  const NotePosition({
    required this.id,
    required this.noteId,
    required this.positionName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note_id'] = Variable<int>(noteId);
    map['position_name'] = Variable<String>(positionName);
    return map;
  }

  NotePositionsCompanion toCompanion(bool nullToAbsent) {
    return NotePositionsCompanion(
      id: Value(id),
      noteId: Value(noteId),
      positionName: Value(positionName),
    );
  }

  factory NotePosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotePosition(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<int>(json['noteId']),
      positionName: serializer.fromJson<String>(json['positionName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<int>(noteId),
      'positionName': serializer.toJson<String>(positionName),
    };
  }

  NotePosition copyWith({int? id, int? noteId, String? positionName}) =>
      NotePosition(
        id: id ?? this.id,
        noteId: noteId ?? this.noteId,
        positionName: positionName ?? this.positionName,
      );
  NotePosition copyWithCompanion(NotePositionsCompanion data) {
    return NotePosition(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      positionName: data.positionName.present
          ? data.positionName.value
          : this.positionName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotePosition(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('positionName: $positionName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noteId, positionName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotePosition &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.positionName == this.positionName);
}

class NotePositionsCompanion extends UpdateCompanion<NotePosition> {
  final Value<int> id;
  final Value<int> noteId;
  final Value<String> positionName;
  const NotePositionsCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.positionName = const Value.absent(),
  });
  NotePositionsCompanion.insert({
    this.id = const Value.absent(),
    required int noteId,
    required String positionName,
  }) : noteId = Value(noteId),
       positionName = Value(positionName);
  static Insertable<NotePosition> custom({
    Expression<int>? id,
    Expression<int>? noteId,
    Expression<String>? positionName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (positionName != null) 'position_name': positionName,
    });
  }

  NotePositionsCompanion copyWith({
    Value<int>? id,
    Value<int>? noteId,
    Value<String>? positionName,
  }) {
    return NotePositionsCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      positionName: positionName ?? this.positionName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (positionName.present) {
      map['position_name'] = Variable<String>(positionName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotePositionsCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('positionName: $positionName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShowMetaTable showMeta = $ShowMetaTable(this);
  late final $UsersLocalTable usersLocal = $UsersLocalTable(this);
  late final $LightingPositionsTable lightingPositions =
      $LightingPositionsTable(this);
  late final $CircuitsTable circuits = $CircuitsTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $AddressesTable addresses = $AddressesTable(this);
  late final $DimmersTable dimmers = $DimmersTable(this);
  late final $FixtureTypesTable fixtureTypes = $FixtureTypesTable(this);
  late final $FixturesTable fixtures = $FixturesTable(this);
  late final $FixturePartsTable fixtureParts = $FixturePartsTable(this);
  late final $GelsTable gels = $GelsTable(this);
  late final $GobosTable gobos = $GobosTable(this);
  late final $AccessoriesTable accessories = $AccessoriesTable(this);
  late final $WorkNotesTable workNotes = $WorkNotesTable(this);
  late final $MaintenanceLogTable maintenanceLog = $MaintenanceLogTable(this);
  late final $CustomFieldsTable customFields = $CustomFieldsTable(this);
  late final $CustomFieldValuesTable customFieldValues =
      $CustomFieldValuesTable(this);
  late final $ReportsTable reports = $ReportsTable(this);
  late final $CommitsTable commits = $CommitsTable(this);
  late final $RevisionsTable revisions = $RevisionsTable(this);
  late final $PositionGroupsTable positionGroups = $PositionGroupsTable(this);
  late final $RoleContactsTable roleContacts = $RoleContactsTable(this);
  late final $SpreadsheetViewPresetsTable spreadsheetViewPresets =
      $SpreadsheetViewPresetsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteActionsTable noteActions = $NoteActionsTable(this);
  late final $NoteFixturesTable noteFixtures = $NoteFixturesTable(this);
  late final $NotePositionsTable notePositions = $NotePositionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    showMeta,
    usersLocal,
    lightingPositions,
    circuits,
    channels,
    addresses,
    dimmers,
    fixtureTypes,
    fixtures,
    fixtureParts,
    gels,
    gobos,
    accessories,
    workNotes,
    maintenanceLog,
    customFields,
    customFieldValues,
    reports,
    commits,
    revisions,
    positionGroups,
    roleContacts,
    spreadsheetViewPresets,
    notes,
    noteActions,
    noteFixtures,
    notePositions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fixture_parts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gels', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixture_parts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gels', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gobos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixture_parts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gobos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('accessories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_notes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_log', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_field_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_fields',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_field_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixture_types',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_actions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_fixtures', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'fixtures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_fixtures', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_positions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ShowMetaTableCreateCompanionBuilder =
    ShowMetaCompanion Function({
      Value<int> id,
      required String showName,
      Value<String?> company,
      Value<String?> orgId,
      required String producer,
      Value<String?> designer,
      Value<String?> designerUserId,
      Value<String?> asstDesigner,
      Value<String?> designBusiness,
      Value<String?> masterElectrician,
      Value<String?> masterElectricianUserId,
      Value<String?> asstMasterElectrician,
      Value<String?> asstMasterElectricianUserId,
      Value<String?> stageManager,
      Value<String?> venue,
      Value<String?> techDate,
      Value<String?> openingDate,
      Value<String?> closingDate,
      Value<String?> mode,
      Value<String?> cloudId,
      required int schemaVersion,
      Value<String?> labelDesigner,
      Value<String?> labelAsstDesigner,
      Value<String?> labelMasterElectrician,
      Value<String?> labelProducer,
      Value<String?> labelAsstMasterElectrician,
      Value<String?> labelStageManager,
    });
typedef $$ShowMetaTableUpdateCompanionBuilder =
    ShowMetaCompanion Function({
      Value<int> id,
      Value<String> showName,
      Value<String?> company,
      Value<String?> orgId,
      Value<String> producer,
      Value<String?> designer,
      Value<String?> designerUserId,
      Value<String?> asstDesigner,
      Value<String?> designBusiness,
      Value<String?> masterElectrician,
      Value<String?> masterElectricianUserId,
      Value<String?> asstMasterElectrician,
      Value<String?> asstMasterElectricianUserId,
      Value<String?> stageManager,
      Value<String?> venue,
      Value<String?> techDate,
      Value<String?> openingDate,
      Value<String?> closingDate,
      Value<String?> mode,
      Value<String?> cloudId,
      Value<int> schemaVersion,
      Value<String?> labelDesigner,
      Value<String?> labelAsstDesigner,
      Value<String?> labelMasterElectrician,
      Value<String?> labelProducer,
      Value<String?> labelAsstMasterElectrician,
      Value<String?> labelStageManager,
    });

class $$ShowMetaTableFilterComposer
    extends Composer<_$AppDatabase, $ShowMetaTable> {
  $$ShowMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get showName => $composableBuilder(
    column: $table.showName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designer => $composableBuilder(
    column: $table.designer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designerUserId => $composableBuilder(
    column: $table.designerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asstDesigner => $composableBuilder(
    column: $table.asstDesigner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designBusiness => $composableBuilder(
    column: $table.designBusiness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masterElectrician => $composableBuilder(
    column: $table.masterElectrician,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get masterElectricianUserId => $composableBuilder(
    column: $table.masterElectricianUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asstMasterElectrician => $composableBuilder(
    column: $table.asstMasterElectrician,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get asstMasterElectricianUserId => $composableBuilder(
    column: $table.asstMasterElectricianUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageManager => $composableBuilder(
    column: $table.stageManager,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get venue => $composableBuilder(
    column: $table.venue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techDate => $composableBuilder(
    column: $table.techDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingDate => $composableBuilder(
    column: $table.openingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closingDate => $composableBuilder(
    column: $table.closingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelDesigner => $composableBuilder(
    column: $table.labelDesigner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelAsstDesigner => $composableBuilder(
    column: $table.labelAsstDesigner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelMasterElectrician => $composableBuilder(
    column: $table.labelMasterElectrician,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelProducer => $composableBuilder(
    column: $table.labelProducer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelAsstMasterElectrician => $composableBuilder(
    column: $table.labelAsstMasterElectrician,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelStageManager => $composableBuilder(
    column: $table.labelStageManager,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShowMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $ShowMetaTable> {
  $$ShowMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get showName => $composableBuilder(
    column: $table.showName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producer => $composableBuilder(
    column: $table.producer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designer => $composableBuilder(
    column: $table.designer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designerUserId => $composableBuilder(
    column: $table.designerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asstDesigner => $composableBuilder(
    column: $table.asstDesigner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designBusiness => $composableBuilder(
    column: $table.designBusiness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masterElectrician => $composableBuilder(
    column: $table.masterElectrician,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get masterElectricianUserId => $composableBuilder(
    column: $table.masterElectricianUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asstMasterElectrician => $composableBuilder(
    column: $table.asstMasterElectrician,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get asstMasterElectricianUserId => $composableBuilder(
    column: $table.asstMasterElectricianUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageManager => $composableBuilder(
    column: $table.stageManager,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get venue => $composableBuilder(
    column: $table.venue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techDate => $composableBuilder(
    column: $table.techDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingDate => $composableBuilder(
    column: $table.openingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closingDate => $composableBuilder(
    column: $table.closingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelDesigner => $composableBuilder(
    column: $table.labelDesigner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelAsstDesigner => $composableBuilder(
    column: $table.labelAsstDesigner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelMasterElectrician => $composableBuilder(
    column: $table.labelMasterElectrician,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelProducer => $composableBuilder(
    column: $table.labelProducer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelAsstMasterElectrician => $composableBuilder(
    column: $table.labelAsstMasterElectrician,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelStageManager => $composableBuilder(
    column: $table.labelStageManager,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShowMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShowMetaTable> {
  $$ShowMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get showName =>
      $composableBuilder(column: $table.showName, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get producer =>
      $composableBuilder(column: $table.producer, builder: (column) => column);

  GeneratedColumn<String> get designer =>
      $composableBuilder(column: $table.designer, builder: (column) => column);

  GeneratedColumn<String> get designerUserId => $composableBuilder(
    column: $table.designerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get asstDesigner => $composableBuilder(
    column: $table.asstDesigner,
    builder: (column) => column,
  );

  GeneratedColumn<String> get designBusiness => $composableBuilder(
    column: $table.designBusiness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get masterElectrician => $composableBuilder(
    column: $table.masterElectrician,
    builder: (column) => column,
  );

  GeneratedColumn<String> get masterElectricianUserId => $composableBuilder(
    column: $table.masterElectricianUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get asstMasterElectrician => $composableBuilder(
    column: $table.asstMasterElectrician,
    builder: (column) => column,
  );

  GeneratedColumn<String> get asstMasterElectricianUserId => $composableBuilder(
    column: $table.asstMasterElectricianUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stageManager => $composableBuilder(
    column: $table.stageManager,
    builder: (column) => column,
  );

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<String> get techDate =>
      $composableBuilder(column: $table.techDate, builder: (column) => column);

  GeneratedColumn<String> get openingDate => $composableBuilder(
    column: $table.openingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closingDate => $composableBuilder(
    column: $table.closingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labelDesigner => $composableBuilder(
    column: $table.labelDesigner,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labelAsstDesigner => $composableBuilder(
    column: $table.labelAsstDesigner,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labelMasterElectrician => $composableBuilder(
    column: $table.labelMasterElectrician,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labelProducer => $composableBuilder(
    column: $table.labelProducer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labelAsstMasterElectrician => $composableBuilder(
    column: $table.labelAsstMasterElectrician,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labelStageManager => $composableBuilder(
    column: $table.labelStageManager,
    builder: (column) => column,
  );
}

class $$ShowMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShowMetaTable,
          ShowMetaData,
          $$ShowMetaTableFilterComposer,
          $$ShowMetaTableOrderingComposer,
          $$ShowMetaTableAnnotationComposer,
          $$ShowMetaTableCreateCompanionBuilder,
          $$ShowMetaTableUpdateCompanionBuilder,
          (
            ShowMetaData,
            BaseReferences<_$AppDatabase, $ShowMetaTable, ShowMetaData>,
          ),
          ShowMetaData,
          PrefetchHooks Function()
        > {
  $$ShowMetaTableTableManager(_$AppDatabase db, $ShowMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShowMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShowMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShowMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> showName = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> orgId = const Value.absent(),
                Value<String> producer = const Value.absent(),
                Value<String?> designer = const Value.absent(),
                Value<String?> designerUserId = const Value.absent(),
                Value<String?> asstDesigner = const Value.absent(),
                Value<String?> designBusiness = const Value.absent(),
                Value<String?> masterElectrician = const Value.absent(),
                Value<String?> masterElectricianUserId = const Value.absent(),
                Value<String?> asstMasterElectrician = const Value.absent(),
                Value<String?> asstMasterElectricianUserId =
                    const Value.absent(),
                Value<String?> stageManager = const Value.absent(),
                Value<String?> venue = const Value.absent(),
                Value<String?> techDate = const Value.absent(),
                Value<String?> openingDate = const Value.absent(),
                Value<String?> closingDate = const Value.absent(),
                Value<String?> mode = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String?> labelDesigner = const Value.absent(),
                Value<String?> labelAsstDesigner = const Value.absent(),
                Value<String?> labelMasterElectrician = const Value.absent(),
                Value<String?> labelProducer = const Value.absent(),
                Value<String?> labelAsstMasterElectrician =
                    const Value.absent(),
                Value<String?> labelStageManager = const Value.absent(),
              }) => ShowMetaCompanion(
                id: id,
                showName: showName,
                company: company,
                orgId: orgId,
                producer: producer,
                designer: designer,
                designerUserId: designerUserId,
                asstDesigner: asstDesigner,
                designBusiness: designBusiness,
                masterElectrician: masterElectrician,
                masterElectricianUserId: masterElectricianUserId,
                asstMasterElectrician: asstMasterElectrician,
                asstMasterElectricianUserId: asstMasterElectricianUserId,
                stageManager: stageManager,
                venue: venue,
                techDate: techDate,
                openingDate: openingDate,
                closingDate: closingDate,
                mode: mode,
                cloudId: cloudId,
                schemaVersion: schemaVersion,
                labelDesigner: labelDesigner,
                labelAsstDesigner: labelAsstDesigner,
                labelMasterElectrician: labelMasterElectrician,
                labelProducer: labelProducer,
                labelAsstMasterElectrician: labelAsstMasterElectrician,
                labelStageManager: labelStageManager,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String showName,
                Value<String?> company = const Value.absent(),
                Value<String?> orgId = const Value.absent(),
                required String producer,
                Value<String?> designer = const Value.absent(),
                Value<String?> designerUserId = const Value.absent(),
                Value<String?> asstDesigner = const Value.absent(),
                Value<String?> designBusiness = const Value.absent(),
                Value<String?> masterElectrician = const Value.absent(),
                Value<String?> masterElectricianUserId = const Value.absent(),
                Value<String?> asstMasterElectrician = const Value.absent(),
                Value<String?> asstMasterElectricianUserId =
                    const Value.absent(),
                Value<String?> stageManager = const Value.absent(),
                Value<String?> venue = const Value.absent(),
                Value<String?> techDate = const Value.absent(),
                Value<String?> openingDate = const Value.absent(),
                Value<String?> closingDate = const Value.absent(),
                Value<String?> mode = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                required int schemaVersion,
                Value<String?> labelDesigner = const Value.absent(),
                Value<String?> labelAsstDesigner = const Value.absent(),
                Value<String?> labelMasterElectrician = const Value.absent(),
                Value<String?> labelProducer = const Value.absent(),
                Value<String?> labelAsstMasterElectrician =
                    const Value.absent(),
                Value<String?> labelStageManager = const Value.absent(),
              }) => ShowMetaCompanion.insert(
                id: id,
                showName: showName,
                company: company,
                orgId: orgId,
                producer: producer,
                designer: designer,
                designerUserId: designerUserId,
                asstDesigner: asstDesigner,
                designBusiness: designBusiness,
                masterElectrician: masterElectrician,
                masterElectricianUserId: masterElectricianUserId,
                asstMasterElectrician: asstMasterElectrician,
                asstMasterElectricianUserId: asstMasterElectricianUserId,
                stageManager: stageManager,
                venue: venue,
                techDate: techDate,
                openingDate: openingDate,
                closingDate: closingDate,
                mode: mode,
                cloudId: cloudId,
                schemaVersion: schemaVersion,
                labelDesigner: labelDesigner,
                labelAsstDesigner: labelAsstDesigner,
                labelMasterElectrician: labelMasterElectrician,
                labelProducer: labelProducer,
                labelAsstMasterElectrician: labelAsstMasterElectrician,
                labelStageManager: labelStageManager,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShowMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShowMetaTable,
      ShowMetaData,
      $$ShowMetaTableFilterComposer,
      $$ShowMetaTableOrderingComposer,
      $$ShowMetaTableAnnotationComposer,
      $$ShowMetaTableCreateCompanionBuilder,
      $$ShowMetaTableUpdateCompanionBuilder,
      (
        ShowMetaData,
        BaseReferences<_$AppDatabase, $ShowMetaTable, ShowMetaData>,
      ),
      ShowMetaData,
      PrefetchHooks Function()
    >;
typedef $$UsersLocalTableCreateCompanionBuilder =
    UsersLocalCompanion Function({
      required String userId,
      required String displayName,
      Value<String?> avatarUrl,
      Value<String?> lastSeen,
      Value<int> rowid,
    });
typedef $$UsersLocalTableUpdateCompanionBuilder =
    UsersLocalCompanion Function({
      Value<String> userId,
      Value<String> displayName,
      Value<String?> avatarUrl,
      Value<String?> lastSeen,
      Value<int> rowid,
    });

class $$UsersLocalTableFilterComposer
    extends Composer<_$AppDatabase, $UsersLocalTable> {
  $$UsersLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersLocalTable> {
  $$UsersLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersLocalTable> {
  $$UsersLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);
}

class $$UsersLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersLocalTable,
          UsersLocalData,
          $$UsersLocalTableFilterComposer,
          $$UsersLocalTableOrderingComposer,
          $$UsersLocalTableAnnotationComposer,
          $$UsersLocalTableCreateCompanionBuilder,
          $$UsersLocalTableUpdateCompanionBuilder,
          (
            UsersLocalData,
            BaseReferences<_$AppDatabase, $UsersLocalTable, UsersLocalData>,
          ),
          UsersLocalData,
          PrefetchHooks Function()
        > {
  $$UsersLocalTableTableManager(_$AppDatabase db, $UsersLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersLocalCompanion(
                userId: userId,
                displayName: displayName,
                avatarUrl: avatarUrl,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String displayName,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersLocalCompanion.insert(
                userId: userId,
                displayName: displayName,
                avatarUrl: avatarUrl,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersLocalTable,
      UsersLocalData,
      $$UsersLocalTableFilterComposer,
      $$UsersLocalTableOrderingComposer,
      $$UsersLocalTableAnnotationComposer,
      $$UsersLocalTableCreateCompanionBuilder,
      $$UsersLocalTableUpdateCompanionBuilder,
      (
        UsersLocalData,
        BaseReferences<_$AppDatabase, $UsersLocalTable, UsersLocalData>,
      ),
      UsersLocalData,
      PrefetchHooks Function()
    >;
typedef $$LightingPositionsTableCreateCompanionBuilder =
    LightingPositionsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> trim,
      Value<String?> fromPlasterLine,
      Value<String?> fromCenterLine,
      Value<int> sortOrder,
      Value<int?> groupId,
    });
typedef $$LightingPositionsTableUpdateCompanionBuilder =
    LightingPositionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> trim,
      Value<String?> fromPlasterLine,
      Value<String?> fromCenterLine,
      Value<int> sortOrder,
      Value<int?> groupId,
    });

class $$LightingPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $LightingPositionsTable> {
  $$LightingPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trim => $composableBuilder(
    column: $table.trim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromPlasterLine => $composableBuilder(
    column: $table.fromPlasterLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromCenterLine => $composableBuilder(
    column: $table.fromCenterLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LightingPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LightingPositionsTable> {
  $$LightingPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trim => $composableBuilder(
    column: $table.trim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromPlasterLine => $composableBuilder(
    column: $table.fromPlasterLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCenterLine => $composableBuilder(
    column: $table.fromCenterLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LightingPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LightingPositionsTable> {
  $$LightingPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get trim =>
      $composableBuilder(column: $table.trim, builder: (column) => column);

  GeneratedColumn<String> get fromPlasterLine => $composableBuilder(
    column: $table.fromPlasterLine,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromCenterLine => $composableBuilder(
    column: $table.fromCenterLine,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);
}

class $$LightingPositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LightingPositionsTable,
          LightingPosition,
          $$LightingPositionsTableFilterComposer,
          $$LightingPositionsTableOrderingComposer,
          $$LightingPositionsTableAnnotationComposer,
          $$LightingPositionsTableCreateCompanionBuilder,
          $$LightingPositionsTableUpdateCompanionBuilder,
          (
            LightingPosition,
            BaseReferences<
              _$AppDatabase,
              $LightingPositionsTable,
              LightingPosition
            >,
          ),
          LightingPosition,
          PrefetchHooks Function()
        > {
  $$LightingPositionsTableTableManager(
    _$AppDatabase db,
    $LightingPositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LightingPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LightingPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LightingPositionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> trim = const Value.absent(),
                Value<String?> fromPlasterLine = const Value.absent(),
                Value<String?> fromCenterLine = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> groupId = const Value.absent(),
              }) => LightingPositionsCompanion(
                id: id,
                name: name,
                trim: trim,
                fromPlasterLine: fromPlasterLine,
                fromCenterLine: fromCenterLine,
                sortOrder: sortOrder,
                groupId: groupId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> trim = const Value.absent(),
                Value<String?> fromPlasterLine = const Value.absent(),
                Value<String?> fromCenterLine = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> groupId = const Value.absent(),
              }) => LightingPositionsCompanion.insert(
                id: id,
                name: name,
                trim: trim,
                fromPlasterLine: fromPlasterLine,
                fromCenterLine: fromCenterLine,
                sortOrder: sortOrder,
                groupId: groupId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LightingPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LightingPositionsTable,
      LightingPosition,
      $$LightingPositionsTableFilterComposer,
      $$LightingPositionsTableOrderingComposer,
      $$LightingPositionsTableAnnotationComposer,
      $$LightingPositionsTableCreateCompanionBuilder,
      $$LightingPositionsTableUpdateCompanionBuilder,
      (
        LightingPosition,
        BaseReferences<
          _$AppDatabase,
          $LightingPositionsTable,
          LightingPosition
        >,
      ),
      LightingPosition,
      PrefetchHooks Function()
    >;
typedef $$CircuitsTableCreateCompanionBuilder =
    CircuitsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> dimmer,
      Value<String?> capacity,
    });
typedef $$CircuitsTableUpdateCompanionBuilder =
    CircuitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> dimmer,
      Value<String?> capacity,
    });

class $$CircuitsTableFilterComposer
    extends Composer<_$AppDatabase, $CircuitsTable> {
  $$CircuitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dimmer => $composableBuilder(
    column: $table.dimmer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CircuitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CircuitsTable> {
  $$CircuitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dimmer => $composableBuilder(
    column: $table.dimmer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CircuitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CircuitsTable> {
  $$CircuitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dimmer =>
      $composableBuilder(column: $table.dimmer, builder: (column) => column);

  GeneratedColumn<String> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);
}

class $$CircuitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CircuitsTable,
          Circuit,
          $$CircuitsTableFilterComposer,
          $$CircuitsTableOrderingComposer,
          $$CircuitsTableAnnotationComposer,
          $$CircuitsTableCreateCompanionBuilder,
          $$CircuitsTableUpdateCompanionBuilder,
          (Circuit, BaseReferences<_$AppDatabase, $CircuitsTable, Circuit>),
          Circuit,
          PrefetchHooks Function()
        > {
  $$CircuitsTableTableManager(_$AppDatabase db, $CircuitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CircuitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CircuitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CircuitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> dimmer = const Value.absent(),
                Value<String?> capacity = const Value.absent(),
              }) => CircuitsCompanion(
                id: id,
                name: name,
                dimmer: dimmer,
                capacity: capacity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> dimmer = const Value.absent(),
                Value<String?> capacity = const Value.absent(),
              }) => CircuitsCompanion.insert(
                id: id,
                name: name,
                dimmer: dimmer,
                capacity: capacity,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CircuitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CircuitsTable,
      Circuit,
      $$CircuitsTableFilterComposer,
      $$CircuitsTableOrderingComposer,
      $$CircuitsTableAnnotationComposer,
      $$CircuitsTableCreateCompanionBuilder,
      $$CircuitsTableUpdateCompanionBuilder,
      (Circuit, BaseReferences<_$AppDatabase, $CircuitsTable, Circuit>),
      Circuit,
      PrefetchHooks Function()
    >;
typedef $$ChannelsTableCreateCompanionBuilder =
    ChannelsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> notes,
    });
typedef $$ChannelsTableUpdateCompanionBuilder =
    ChannelsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> notes,
    });

class $$ChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ChannelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChannelsTable,
          Channel,
          $$ChannelsTableFilterComposer,
          $$ChannelsTableOrderingComposer,
          $$ChannelsTableAnnotationComposer,
          $$ChannelsTableCreateCompanionBuilder,
          $$ChannelsTableUpdateCompanionBuilder,
          (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
          Channel,
          PrefetchHooks Function()
        > {
  $$ChannelsTableTableManager(_$AppDatabase db, $ChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ChannelsCompanion(id: id, name: name, notes: notes),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> notes = const Value.absent(),
              }) => ChannelsCompanion.insert(id: id, name: name, notes: notes),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChannelsTable,
      Channel,
      $$ChannelsTableFilterComposer,
      $$ChannelsTableOrderingComposer,
      $$ChannelsTableAnnotationComposer,
      $$ChannelsTableCreateCompanionBuilder,
      $$ChannelsTableUpdateCompanionBuilder,
      (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
      Channel,
      PrefetchHooks Function()
    >;
typedef $$AddressesTableCreateCompanionBuilder =
    AddressesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> type,
      Value<String?> channel,
    });
typedef $$AddressesTableUpdateCompanionBuilder =
    AddressesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> type,
      Value<String?> channel,
    });

class $$AddressesTableFilterComposer
    extends Composer<_$AppDatabase, $AddressesTable> {
  $$AddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AddressesTableOrderingComposer
    extends Composer<_$AppDatabase, $AddressesTable> {
  $$AddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AddressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AddressesTable> {
  $$AddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);
}

class $$AddressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AddressesTable,
          AddressesData,
          $$AddressesTableFilterComposer,
          $$AddressesTableOrderingComposer,
          $$AddressesTableAnnotationComposer,
          $$AddressesTableCreateCompanionBuilder,
          $$AddressesTableUpdateCompanionBuilder,
          (
            AddressesData,
            BaseReferences<_$AppDatabase, $AddressesTable, AddressesData>,
          ),
          AddressesData,
          PrefetchHooks Function()
        > {
  $$AddressesTableTableManager(_$AppDatabase db, $AddressesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AddressesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> channel = const Value.absent(),
              }) => AddressesCompanion(
                id: id,
                name: name,
                type: type,
                channel: channel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> type = const Value.absent(),
                Value<String?> channel = const Value.absent(),
              }) => AddressesCompanion.insert(
                id: id,
                name: name,
                type: type,
                channel: channel,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AddressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AddressesTable,
      AddressesData,
      $$AddressesTableFilterComposer,
      $$AddressesTableOrderingComposer,
      $$AddressesTableAnnotationComposer,
      $$AddressesTableCreateCompanionBuilder,
      $$AddressesTableUpdateCompanionBuilder,
      (
        AddressesData,
        BaseReferences<_$AppDatabase, $AddressesTable, AddressesData>,
      ),
      AddressesData,
      PrefetchHooks Function()
    >;
typedef $$DimmersTableCreateCompanionBuilder =
    DimmersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> address,
      Value<String?> pack,
      Value<String?> rack,
      Value<String?> location,
      Value<String?> capacity,
    });
typedef $$DimmersTableUpdateCompanionBuilder =
    DimmersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> address,
      Value<String?> pack,
      Value<String?> rack,
      Value<String?> location,
      Value<String?> capacity,
    });

class $$DimmersTableFilterComposer
    extends Composer<_$AppDatabase, $DimmersTable> {
  $$DimmersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pack => $composableBuilder(
    column: $table.pack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rack => $composableBuilder(
    column: $table.rack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DimmersTableOrderingComposer
    extends Composer<_$AppDatabase, $DimmersTable> {
  $$DimmersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pack => $composableBuilder(
    column: $table.pack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rack => $composableBuilder(
    column: $table.rack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DimmersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DimmersTable> {
  $$DimmersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get pack =>
      $composableBuilder(column: $table.pack, builder: (column) => column);

  GeneratedColumn<String> get rack =>
      $composableBuilder(column: $table.rack, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);
}

class $$DimmersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DimmersTable,
          Dimmer,
          $$DimmersTableFilterComposer,
          $$DimmersTableOrderingComposer,
          $$DimmersTableAnnotationComposer,
          $$DimmersTableCreateCompanionBuilder,
          $$DimmersTableUpdateCompanionBuilder,
          (Dimmer, BaseReferences<_$AppDatabase, $DimmersTable, Dimmer>),
          Dimmer,
          PrefetchHooks Function()
        > {
  $$DimmersTableTableManager(_$AppDatabase db, $DimmersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DimmersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DimmersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DimmersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> pack = const Value.absent(),
                Value<String?> rack = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> capacity = const Value.absent(),
              }) => DimmersCompanion(
                id: id,
                name: name,
                address: address,
                pack: pack,
                rack: rack,
                location: location,
                capacity: capacity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> address = const Value.absent(),
                Value<String?> pack = const Value.absent(),
                Value<String?> rack = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> capacity = const Value.absent(),
              }) => DimmersCompanion.insert(
                id: id,
                name: name,
                address: address,
                pack: pack,
                rack: rack,
                location: location,
                capacity: capacity,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DimmersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DimmersTable,
      Dimmer,
      $$DimmersTableFilterComposer,
      $$DimmersTableOrderingComposer,
      $$DimmersTableAnnotationComposer,
      $$DimmersTableCreateCompanionBuilder,
      $$DimmersTableUpdateCompanionBuilder,
      (Dimmer, BaseReferences<_$AppDatabase, $DimmersTable, Dimmer>),
      Dimmer,
      PrefetchHooks Function()
    >;
typedef $$FixtureTypesTableCreateCompanionBuilder =
    FixtureTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> wattage,
      Value<int> partCount,
      Value<String?> defaultPartsJson,
    });
typedef $$FixtureTypesTableUpdateCompanionBuilder =
    FixtureTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> wattage,
      Value<int> partCount,
      Value<String?> defaultPartsJson,
    });

final class $$FixtureTypesTableReferences
    extends BaseReferences<_$AppDatabase, $FixtureTypesTable, FixtureType> {
  $$FixtureTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FixturesTable, List<Fixture>> _fixturesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.fixtures,
    aliasName: $_aliasNameGenerator(
      db.fixtureTypes.id,
      db.fixtures.fixtureTypeId,
    ),
  );

  $$FixturesTableProcessedTableManager get fixturesRefs {
    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.fixtureTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fixturesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: $_aliasNameGenerator(db.fixtureTypes.id, db.notes.fixtureTypeId),
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.fixtureTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FixtureTypesTableFilterComposer
    extends Composer<_$AppDatabase, $FixtureTypesTable> {
  $$FixtureTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wattage => $composableBuilder(
    column: $table.wattage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partCount => $composableBuilder(
    column: $table.partCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultPartsJson => $composableBuilder(
    column: $table.defaultPartsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fixturesRefs(
    Expression<bool> Function($$FixturesTableFilterComposer f) f,
  ) {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.fixtureTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.fixtureTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixtureTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $FixtureTypesTable> {
  $$FixtureTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wattage => $composableBuilder(
    column: $table.wattage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partCount => $composableBuilder(
    column: $table.partCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultPartsJson => $composableBuilder(
    column: $table.defaultPartsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FixtureTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixtureTypesTable> {
  $$FixtureTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get wattage =>
      $composableBuilder(column: $table.wattage, builder: (column) => column);

  GeneratedColumn<int> get partCount =>
      $composableBuilder(column: $table.partCount, builder: (column) => column);

  GeneratedColumn<String> get defaultPartsJson => $composableBuilder(
    column: $table.defaultPartsJson,
    builder: (column) => column,
  );

  Expression<T> fixturesRefs<T extends Object>(
    Expression<T> Function($$FixturesTableAnnotationComposer a) f,
  ) {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.fixtureTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.fixtureTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixtureTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixtureTypesTable,
          FixtureType,
          $$FixtureTypesTableFilterComposer,
          $$FixtureTypesTableOrderingComposer,
          $$FixtureTypesTableAnnotationComposer,
          $$FixtureTypesTableCreateCompanionBuilder,
          $$FixtureTypesTableUpdateCompanionBuilder,
          (FixtureType, $$FixtureTypesTableReferences),
          FixtureType,
          PrefetchHooks Function({bool fixturesRefs, bool notesRefs})
        > {
  $$FixtureTypesTableTableManager(_$AppDatabase db, $FixtureTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixtureTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixtureTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixtureTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> wattage = const Value.absent(),
                Value<int> partCount = const Value.absent(),
                Value<String?> defaultPartsJson = const Value.absent(),
              }) => FixtureTypesCompanion(
                id: id,
                name: name,
                wattage: wattage,
                partCount: partCount,
                defaultPartsJson: defaultPartsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> wattage = const Value.absent(),
                Value<int> partCount = const Value.absent(),
                Value<String?> defaultPartsJson = const Value.absent(),
              }) => FixtureTypesCompanion.insert(
                id: id,
                name: name,
                wattage: wattage,
                partCount: partCount,
                defaultPartsJson: defaultPartsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FixtureTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fixturesRefs = false, notesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (fixturesRefs) db.fixtures,
                if (notesRefs) db.notes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (fixturesRefs)
                    await $_getPrefetchedData<
                      FixtureType,
                      $FixtureTypesTable,
                      Fixture
                    >(
                      currentTable: table,
                      referencedTable: $$FixtureTypesTableReferences
                          ._fixturesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FixtureTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).fixturesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.fixtureTypeId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (notesRefs)
                    await $_getPrefetchedData<
                      FixtureType,
                      $FixtureTypesTable,
                      Note
                    >(
                      currentTable: table,
                      referencedTable: $$FixtureTypesTableReferences
                          ._notesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FixtureTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).notesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.fixtureTypeId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FixtureTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixtureTypesTable,
      FixtureType,
      $$FixtureTypesTableFilterComposer,
      $$FixtureTypesTableOrderingComposer,
      $$FixtureTypesTableAnnotationComposer,
      $$FixtureTypesTableCreateCompanionBuilder,
      $$FixtureTypesTableUpdateCompanionBuilder,
      (FixtureType, $$FixtureTypesTableReferences),
      FixtureType,
      PrefetchHooks Function({bool fixturesRefs, bool notesRefs})
    >;
typedef $$FixturesTableCreateCompanionBuilder =
    FixturesCompanion Function({
      Value<int> id,
      Value<int?> fixtureTypeId,
      Value<String?> fixtureType,
      Value<String?> position,
      Value<int?> unitNumber,
      Value<String?> wattage,
      Value<String?> function,
      Value<String?> focus,
      Value<int> flagged,
      Value<double> sortOrder,
      Value<String?> accessories,
      Value<int> hung,
      Value<int> focused,
      Value<int> patched,
      Value<int> deleted,
    });
typedef $$FixturesTableUpdateCompanionBuilder =
    FixturesCompanion Function({
      Value<int> id,
      Value<int?> fixtureTypeId,
      Value<String?> fixtureType,
      Value<String?> position,
      Value<int?> unitNumber,
      Value<String?> wattage,
      Value<String?> function,
      Value<String?> focus,
      Value<int> flagged,
      Value<double> sortOrder,
      Value<String?> accessories,
      Value<int> hung,
      Value<int> focused,
      Value<int> patched,
      Value<int> deleted,
    });

final class $$FixturesTableReferences
    extends BaseReferences<_$AppDatabase, $FixturesTable, Fixture> {
  $$FixturesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixtureTypesTable _fixtureTypeIdTable(_$AppDatabase db) =>
      db.fixtureTypes.createAlias(
        $_aliasNameGenerator(db.fixtures.fixtureTypeId, db.fixtureTypes.id),
      );

  $$FixtureTypesTableProcessedTableManager? get fixtureTypeId {
    final $_column = $_itemColumn<int>('fixture_type_id');
    if ($_column == null) return null;
    final manager = $$FixtureTypesTableTableManager(
      $_db,
      $_db.fixtureTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FixturePartsTable, List<FixturePart>>
  _fixturePartsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fixtureParts,
    aliasName: $_aliasNameGenerator(db.fixtures.id, db.fixtureParts.fixtureId),
  );

  $$FixturePartsTableProcessedTableManager get fixturePartsRefs {
    final manager = $$FixturePartsTableTableManager(
      $_db,
      $_db.fixtureParts,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fixturePartsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GelsTable, List<Gel>> _gelsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gels,
    aliasName: $_aliasNameGenerator(db.fixtures.id, db.gels.fixtureId),
  );

  $$GelsTableProcessedTableManager get gelsRefs {
    final manager = $$GelsTableTableManager(
      $_db,
      $_db.gels,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GobosTable, List<Gobo>> _gobosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gobos,
    aliasName: $_aliasNameGenerator(db.fixtures.id, db.gobos.fixtureId),
  );

  $$GobosTableProcessedTableManager get gobosRefs {
    final manager = $$GobosTableTableManager(
      $_db,
      $_db.gobos,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gobosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AccessoriesTable, List<Accessory>>
  _accessoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.accessories,
    aliasName: $_aliasNameGenerator(db.fixtures.id, db.accessories.fixtureId),
  );

  $$AccessoriesTableProcessedTableManager get accessoriesRefs {
    final manager = $$AccessoriesTableTableManager(
      $_db,
      $_db.accessories,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_accessoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkNotesTable, List<WorkNote>>
  _workNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workNotes,
    aliasName: $_aliasNameGenerator(db.fixtures.id, db.workNotes.fixtureId),
  );

  $$WorkNotesTableProcessedTableManager get workNotesRefs {
    final manager = $$WorkNotesTableTableManager(
      $_db,
      $_db.workNotes,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceLogTable, List<MaintenanceLogData>>
  _maintenanceLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.maintenanceLog,
    aliasName: $_aliasNameGenerator(
      db.fixtures.id,
      db.maintenanceLog.fixtureId,
    ),
  );

  $$MaintenanceLogTableProcessedTableManager get maintenanceLogRefs {
    final manager = $$MaintenanceLogTableTableManager(
      $_db,
      $_db.maintenanceLog,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_maintenanceLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomFieldValuesTable, List<CustomFieldValue>>
  _customFieldValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customFieldValues,
        aliasName: $_aliasNameGenerator(
          db.fixtures.id,
          db.customFieldValues.fixtureId,
        ),
      );

  $$CustomFieldValuesTableProcessedTableManager get customFieldValuesRefs {
    final manager = $$CustomFieldValuesTableTableManager(
      $_db,
      $_db.customFieldValues,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customFieldValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteFixturesTable, List<NoteFixture>>
  _noteFixturesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteFixtures,
    aliasName: $_aliasNameGenerator(db.fixtures.id, db.noteFixtures.fixtureId),
  );

  $$NoteFixturesTableProcessedTableManager get noteFixturesRefs {
    final manager = $$NoteFixturesTableTableManager(
      $_db,
      $_db.noteFixtures,
    ).filter((f) => f.fixtureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteFixturesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FixturesTableFilterComposer
    extends Composer<_$AppDatabase, $FixturesTable> {
  $$FixturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fixtureType => $composableBuilder(
    column: $table.fixtureType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitNumber => $composableBuilder(
    column: $table.unitNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wattage => $composableBuilder(
    column: $table.wattage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get function => $composableBuilder(
    column: $table.function,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flagged => $composableBuilder(
    column: $table.flagged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessories => $composableBuilder(
    column: $table.accessories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hung => $composableBuilder(
    column: $table.hung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focused => $composableBuilder(
    column: $table.focused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get patched => $composableBuilder(
    column: $table.patched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  $$FixtureTypesTableFilterComposer get fixtureTypeId {
    final $$FixtureTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureTypeId,
      referencedTable: $db.fixtureTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureTypesTableFilterComposer(
            $db: $db,
            $table: $db.fixtureTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> fixturePartsRefs(
    Expression<bool> Function($$FixturePartsTableFilterComposer f) f,
  ) {
    final $$FixturePartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableFilterComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gelsRefs(
    Expression<bool> Function($$GelsTableFilterComposer f) f,
  ) {
    final $$GelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gels,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GelsTableFilterComposer(
            $db: $db,
            $table: $db.gels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gobosRefs(
    Expression<bool> Function($$GobosTableFilterComposer f) f,
  ) {
    final $$GobosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gobos,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GobosTableFilterComposer(
            $db: $db,
            $table: $db.gobos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> accessoriesRefs(
    Expression<bool> Function($$AccessoriesTableFilterComposer f) f,
  ) {
    final $$AccessoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accessories,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccessoriesTableFilterComposer(
            $db: $db,
            $table: $db.accessories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workNotesRefs(
    Expression<bool> Function($$WorkNotesTableFilterComposer f) f,
  ) {
    final $$WorkNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workNotes,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkNotesTableFilterComposer(
            $db: $db,
            $table: $db.workNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceLogRefs(
    Expression<bool> Function($$MaintenanceLogTableFilterComposer f) f,
  ) {
    final $$MaintenanceLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceLog,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceLogTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customFieldValuesRefs(
    Expression<bool> Function($$CustomFieldValuesTableFilterComposer f) f,
  ) {
    final $$CustomFieldValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customFieldValues,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomFieldValuesTableFilterComposer(
            $db: $db,
            $table: $db.customFieldValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteFixturesRefs(
    Expression<bool> Function($$NoteFixturesTableFilterComposer f) f,
  ) {
    final $$NoteFixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFixtures,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFixturesTableFilterComposer(
            $db: $db,
            $table: $db.noteFixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixturesTableOrderingComposer
    extends Composer<_$AppDatabase, $FixturesTable> {
  $$FixturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixtureType => $composableBuilder(
    column: $table.fixtureType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitNumber => $composableBuilder(
    column: $table.unitNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wattage => $composableBuilder(
    column: $table.wattage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get function => $composableBuilder(
    column: $table.function,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flagged => $composableBuilder(
    column: $table.flagged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessories => $composableBuilder(
    column: $table.accessories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hung => $composableBuilder(
    column: $table.hung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focused => $composableBuilder(
    column: $table.focused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get patched => $composableBuilder(
    column: $table.patched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixtureTypesTableOrderingComposer get fixtureTypeId {
    final $$FixtureTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureTypeId,
      referencedTable: $db.fixtureTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureTypesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtureTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixturesTable> {
  $$FixturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fixtureType => $composableBuilder(
    column: $table.fixtureType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get unitNumber => $composableBuilder(
    column: $table.unitNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wattage =>
      $composableBuilder(column: $table.wattage, builder: (column) => column);

  GeneratedColumn<String> get function =>
      $composableBuilder(column: $table.function, builder: (column) => column);

  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<int> get flagged =>
      $composableBuilder(column: $table.flagged, builder: (column) => column);

  GeneratedColumn<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get accessories => $composableBuilder(
    column: $table.accessories,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hung =>
      $composableBuilder(column: $table.hung, builder: (column) => column);

  GeneratedColumn<int> get focused =>
      $composableBuilder(column: $table.focused, builder: (column) => column);

  GeneratedColumn<int> get patched =>
      $composableBuilder(column: $table.patched, builder: (column) => column);

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  $$FixtureTypesTableAnnotationComposer get fixtureTypeId {
    final $$FixtureTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureTypeId,
      referencedTable: $db.fixtureTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtureTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> fixturePartsRefs<T extends Object>(
    Expression<T> Function($$FixturePartsTableAnnotationComposer a) f,
  ) {
    final $$FixturePartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gelsRefs<T extends Object>(
    Expression<T> Function($$GelsTableAnnotationComposer a) f,
  ) {
    final $$GelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gels,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GelsTableAnnotationComposer(
            $db: $db,
            $table: $db.gels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gobosRefs<T extends Object>(
    Expression<T> Function($$GobosTableAnnotationComposer a) f,
  ) {
    final $$GobosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gobos,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GobosTableAnnotationComposer(
            $db: $db,
            $table: $db.gobos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> accessoriesRefs<T extends Object>(
    Expression<T> Function($$AccessoriesTableAnnotationComposer a) f,
  ) {
    final $$AccessoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accessories,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccessoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.accessories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workNotesRefs<T extends Object>(
    Expression<T> Function($$WorkNotesTableAnnotationComposer a) f,
  ) {
    final $$WorkNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workNotes,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.workNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceLogRefs<T extends Object>(
    Expression<T> Function($$MaintenanceLogTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceLog,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceLogTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customFieldValuesRefs<T extends Object>(
    Expression<T> Function($$CustomFieldValuesTableAnnotationComposer a) f,
  ) {
    final $$CustomFieldValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customFieldValues,
          getReferencedColumn: (t) => t.fixtureId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomFieldValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.customFieldValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> noteFixturesRefs<T extends Object>(
    Expression<T> Function($$NoteFixturesTableAnnotationComposer a) f,
  ) {
    final $$NoteFixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFixtures,
      getReferencedColumn: (t) => t.fixtureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.noteFixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixturesTable,
          Fixture,
          $$FixturesTableFilterComposer,
          $$FixturesTableOrderingComposer,
          $$FixturesTableAnnotationComposer,
          $$FixturesTableCreateCompanionBuilder,
          $$FixturesTableUpdateCompanionBuilder,
          (Fixture, $$FixturesTableReferences),
          Fixture,
          PrefetchHooks Function({
            bool fixtureTypeId,
            bool fixturePartsRefs,
            bool gelsRefs,
            bool gobosRefs,
            bool accessoriesRefs,
            bool workNotesRefs,
            bool maintenanceLogRefs,
            bool customFieldValuesRefs,
            bool noteFixturesRefs,
          })
        > {
  $$FixturesTableTableManager(_$AppDatabase db, $FixturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> fixtureTypeId = const Value.absent(),
                Value<String?> fixtureType = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<int?> unitNumber = const Value.absent(),
                Value<String?> wattage = const Value.absent(),
                Value<String?> function = const Value.absent(),
                Value<String?> focus = const Value.absent(),
                Value<int> flagged = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String?> accessories = const Value.absent(),
                Value<int> hung = const Value.absent(),
                Value<int> focused = const Value.absent(),
                Value<int> patched = const Value.absent(),
                Value<int> deleted = const Value.absent(),
              }) => FixturesCompanion(
                id: id,
                fixtureTypeId: fixtureTypeId,
                fixtureType: fixtureType,
                position: position,
                unitNumber: unitNumber,
                wattage: wattage,
                function: function,
                focus: focus,
                flagged: flagged,
                sortOrder: sortOrder,
                accessories: accessories,
                hung: hung,
                focused: focused,
                patched: patched,
                deleted: deleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> fixtureTypeId = const Value.absent(),
                Value<String?> fixtureType = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<int?> unitNumber = const Value.absent(),
                Value<String?> wattage = const Value.absent(),
                Value<String?> function = const Value.absent(),
                Value<String?> focus = const Value.absent(),
                Value<int> flagged = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<String?> accessories = const Value.absent(),
                Value<int> hung = const Value.absent(),
                Value<int> focused = const Value.absent(),
                Value<int> patched = const Value.absent(),
                Value<int> deleted = const Value.absent(),
              }) => FixturesCompanion.insert(
                id: id,
                fixtureTypeId: fixtureTypeId,
                fixtureType: fixtureType,
                position: position,
                unitNumber: unitNumber,
                wattage: wattage,
                function: function,
                focus: focus,
                flagged: flagged,
                sortOrder: sortOrder,
                accessories: accessories,
                hung: hung,
                focused: focused,
                patched: patched,
                deleted: deleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FixturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fixtureTypeId = false,
                fixturePartsRefs = false,
                gelsRefs = false,
                gobosRefs = false,
                accessoriesRefs = false,
                workNotesRefs = false,
                maintenanceLogRefs = false,
                customFieldValuesRefs = false,
                noteFixturesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fixturePartsRefs) db.fixtureParts,
                    if (gelsRefs) db.gels,
                    if (gobosRefs) db.gobos,
                    if (accessoriesRefs) db.accessories,
                    if (workNotesRefs) db.workNotes,
                    if (maintenanceLogRefs) db.maintenanceLog,
                    if (customFieldValuesRefs) db.customFieldValues,
                    if (noteFixturesRefs) db.noteFixtures,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fixtureTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fixtureTypeId,
                                    referencedTable: $$FixturesTableReferences
                                        ._fixtureTypeIdTable(db),
                                    referencedColumn: $$FixturesTableReferences
                                        ._fixtureTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fixturePartsRefs)
                        await $_getPrefetchedData<
                          Fixture,
                          $FixturesTable,
                          FixturePart
                        >(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._fixturePartsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(
                                db,
                                table,
                                p0,
                              ).fixturePartsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gelsRefs)
                        await $_getPrefetchedData<Fixture, $FixturesTable, Gel>(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._gelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(db, table, p0).gelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gobosRefs)
                        await $_getPrefetchedData<
                          Fixture,
                          $FixturesTable,
                          Gobo
                        >(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._gobosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(
                                db,
                                table,
                                p0,
                              ).gobosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (accessoriesRefs)
                        await $_getPrefetchedData<
                          Fixture,
                          $FixturesTable,
                          Accessory
                        >(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._accessoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(
                                db,
                                table,
                                p0,
                              ).accessoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workNotesRefs)
                        await $_getPrefetchedData<
                          Fixture,
                          $FixturesTable,
                          WorkNote
                        >(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._workNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(
                                db,
                                table,
                                p0,
                              ).workNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceLogRefs)
                        await $_getPrefetchedData<
                          Fixture,
                          $FixturesTable,
                          MaintenanceLogData
                        >(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._maintenanceLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customFieldValuesRefs)
                        await $_getPrefetchedData<
                          Fixture,
                          $FixturesTable,
                          CustomFieldValue
                        >(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._customFieldValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(
                                db,
                                table,
                                p0,
                              ).customFieldValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteFixturesRefs)
                        await $_getPrefetchedData<
                          Fixture,
                          $FixturesTable,
                          NoteFixture
                        >(
                          currentTable: table,
                          referencedTable: $$FixturesTableReferences
                              ._noteFixturesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteFixturesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixtureId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FixturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixturesTable,
      Fixture,
      $$FixturesTableFilterComposer,
      $$FixturesTableOrderingComposer,
      $$FixturesTableAnnotationComposer,
      $$FixturesTableCreateCompanionBuilder,
      $$FixturesTableUpdateCompanionBuilder,
      (Fixture, $$FixturesTableReferences),
      Fixture,
      PrefetchHooks Function({
        bool fixtureTypeId,
        bool fixturePartsRefs,
        bool gelsRefs,
        bool gobosRefs,
        bool accessoriesRefs,
        bool workNotesRefs,
        bool maintenanceLogRefs,
        bool customFieldValuesRefs,
        bool noteFixturesRefs,
      })
    >;
typedef $$FixturePartsTableCreateCompanionBuilder =
    FixturePartsCompanion Function({
      Value<int> id,
      required int fixtureId,
      required int partOrder,
      Value<String?> partType,
      Value<String?> partName,
      Value<String?> channel,
      Value<String?> address,
      Value<String?> circuit,
      Value<String?> ipAddress,
      Value<String?> macAddress,
      Value<String?> subnet,
      Value<String?> ipv6,
      Value<String?> extrasJson,
      Value<int> deleted,
    });
typedef $$FixturePartsTableUpdateCompanionBuilder =
    FixturePartsCompanion Function({
      Value<int> id,
      Value<int> fixtureId,
      Value<int> partOrder,
      Value<String?> partType,
      Value<String?> partName,
      Value<String?> channel,
      Value<String?> address,
      Value<String?> circuit,
      Value<String?> ipAddress,
      Value<String?> macAddress,
      Value<String?> subnet,
      Value<String?> ipv6,
      Value<String?> extrasJson,
      Value<int> deleted,
    });

final class $$FixturePartsTableReferences
    extends BaseReferences<_$AppDatabase, $FixturePartsTable, FixturePart> {
  $$FixturePartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) =>
      db.fixtures.createAlias(
        $_aliasNameGenerator(db.fixtureParts.fixtureId, db.fixtures.id),
      );

  $$FixturesTableProcessedTableManager get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id')!;

    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GelsTable, List<Gel>> _gelsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gels,
    aliasName: $_aliasNameGenerator(db.fixtureParts.id, db.gels.fixturePartId),
  );

  $$GelsTableProcessedTableManager get gelsRefs {
    final manager = $$GelsTableTableManager(
      $_db,
      $_db.gels,
    ).filter((f) => f.fixturePartId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GobosTable, List<Gobo>> _gobosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gobos,
    aliasName: $_aliasNameGenerator(db.fixtureParts.id, db.gobos.fixturePartId),
  );

  $$GobosTableProcessedTableManager get gobosRefs {
    final manager = $$GobosTableTableManager(
      $_db,
      $_db.gobos,
    ).filter((f) => f.fixturePartId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gobosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FixturePartsTableFilterComposer
    extends Composer<_$AppDatabase, $FixturePartsTable> {
  $$FixturePartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partOrder => $composableBuilder(
    column: $table.partOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partType => $composableBuilder(
    column: $table.partType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partName => $composableBuilder(
    column: $table.partName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circuit => $composableBuilder(
    column: $table.circuit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subnet => $composableBuilder(
    column: $table.subnet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipv6 => $composableBuilder(
    column: $table.ipv6,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrasJson => $composableBuilder(
    column: $table.extrasJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gelsRefs(
    Expression<bool> Function($$GelsTableFilterComposer f) f,
  ) {
    final $$GelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gels,
      getReferencedColumn: (t) => t.fixturePartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GelsTableFilterComposer(
            $db: $db,
            $table: $db.gels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gobosRefs(
    Expression<bool> Function($$GobosTableFilterComposer f) f,
  ) {
    final $$GobosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gobos,
      getReferencedColumn: (t) => t.fixturePartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GobosTableFilterComposer(
            $db: $db,
            $table: $db.gobos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixturePartsTableOrderingComposer
    extends Composer<_$AppDatabase, $FixturePartsTable> {
  $$FixturePartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partOrder => $composableBuilder(
    column: $table.partOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partType => $composableBuilder(
    column: $table.partType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partName => $composableBuilder(
    column: $table.partName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circuit => $composableBuilder(
    column: $table.circuit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subnet => $composableBuilder(
    column: $table.subnet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipv6 => $composableBuilder(
    column: $table.ipv6,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrasJson => $composableBuilder(
    column: $table.extrasJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixturePartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixturePartsTable> {
  $$FixturePartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get partOrder =>
      $composableBuilder(column: $table.partOrder, builder: (column) => column);

  GeneratedColumn<String> get partType =>
      $composableBuilder(column: $table.partType, builder: (column) => column);

  GeneratedColumn<String> get partName =>
      $composableBuilder(column: $table.partName, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get circuit =>
      $composableBuilder(column: $table.circuit, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subnet =>
      $composableBuilder(column: $table.subnet, builder: (column) => column);

  GeneratedColumn<String> get ipv6 =>
      $composableBuilder(column: $table.ipv6, builder: (column) => column);

  GeneratedColumn<String> get extrasJson => $composableBuilder(
    column: $table.extrasJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gelsRefs<T extends Object>(
    Expression<T> Function($$GelsTableAnnotationComposer a) f,
  ) {
    final $$GelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gels,
      getReferencedColumn: (t) => t.fixturePartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GelsTableAnnotationComposer(
            $db: $db,
            $table: $db.gels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gobosRefs<T extends Object>(
    Expression<T> Function($$GobosTableAnnotationComposer a) f,
  ) {
    final $$GobosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gobos,
      getReferencedColumn: (t) => t.fixturePartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GobosTableAnnotationComposer(
            $db: $db,
            $table: $db.gobos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixturePartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixturePartsTable,
          FixturePart,
          $$FixturePartsTableFilterComposer,
          $$FixturePartsTableOrderingComposer,
          $$FixturePartsTableAnnotationComposer,
          $$FixturePartsTableCreateCompanionBuilder,
          $$FixturePartsTableUpdateCompanionBuilder,
          (FixturePart, $$FixturePartsTableReferences),
          FixturePart,
          PrefetchHooks Function({
            bool fixtureId,
            bool gelsRefs,
            bool gobosRefs,
          })
        > {
  $$FixturePartsTableTableManager(_$AppDatabase db, $FixturePartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixturePartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixturePartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixturePartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fixtureId = const Value.absent(),
                Value<int> partOrder = const Value.absent(),
                Value<String?> partType = const Value.absent(),
                Value<String?> partName = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> circuit = const Value.absent(),
                Value<String?> ipAddress = const Value.absent(),
                Value<String?> macAddress = const Value.absent(),
                Value<String?> subnet = const Value.absent(),
                Value<String?> ipv6 = const Value.absent(),
                Value<String?> extrasJson = const Value.absent(),
                Value<int> deleted = const Value.absent(),
              }) => FixturePartsCompanion(
                id: id,
                fixtureId: fixtureId,
                partOrder: partOrder,
                partType: partType,
                partName: partName,
                channel: channel,
                address: address,
                circuit: circuit,
                ipAddress: ipAddress,
                macAddress: macAddress,
                subnet: subnet,
                ipv6: ipv6,
                extrasJson: extrasJson,
                deleted: deleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fixtureId,
                required int partOrder,
                Value<String?> partType = const Value.absent(),
                Value<String?> partName = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> circuit = const Value.absent(),
                Value<String?> ipAddress = const Value.absent(),
                Value<String?> macAddress = const Value.absent(),
                Value<String?> subnet = const Value.absent(),
                Value<String?> ipv6 = const Value.absent(),
                Value<String?> extrasJson = const Value.absent(),
                Value<int> deleted = const Value.absent(),
              }) => FixturePartsCompanion.insert(
                id: id,
                fixtureId: fixtureId,
                partOrder: partOrder,
                partType: partType,
                partName: partName,
                channel: channel,
                address: address,
                circuit: circuit,
                ipAddress: ipAddress,
                macAddress: macAddress,
                subnet: subnet,
                ipv6: ipv6,
                extrasJson: extrasJson,
                deleted: deleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FixturePartsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({fixtureId = false, gelsRefs = false, gobosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gelsRefs) db.gels,
                    if (gobosRefs) db.gobos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fixtureId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fixtureId,
                                    referencedTable:
                                        $$FixturePartsTableReferences
                                            ._fixtureIdTable(db),
                                    referencedColumn:
                                        $$FixturePartsTableReferences
                                            ._fixtureIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gelsRefs)
                        await $_getPrefetchedData<
                          FixturePart,
                          $FixturePartsTable,
                          Gel
                        >(
                          currentTable: table,
                          referencedTable: $$FixturePartsTableReferences
                              ._gelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturePartsTableReferences(
                                db,
                                table,
                                p0,
                              ).gelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixturePartId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gobosRefs)
                        await $_getPrefetchedData<
                          FixturePart,
                          $FixturePartsTable,
                          Gobo
                        >(
                          currentTable: table,
                          referencedTable: $$FixturePartsTableReferences
                              ._gobosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FixturePartsTableReferences(
                                db,
                                table,
                                p0,
                              ).gobosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fixturePartId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FixturePartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixturePartsTable,
      FixturePart,
      $$FixturePartsTableFilterComposer,
      $$FixturePartsTableOrderingComposer,
      $$FixturePartsTableAnnotationComposer,
      $$FixturePartsTableCreateCompanionBuilder,
      $$FixturePartsTableUpdateCompanionBuilder,
      (FixturePart, $$FixturePartsTableReferences),
      FixturePart,
      PrefetchHooks Function({bool fixtureId, bool gelsRefs, bool gobosRefs})
    >;
typedef $$GelsTableCreateCompanionBuilder =
    GelsCompanion Function({
      Value<int> id,
      required String color,
      required int fixtureId,
      Value<int?> fixturePartId,
      Value<String?> size,
      Value<String?> maker,
    });
typedef $$GelsTableUpdateCompanionBuilder =
    GelsCompanion Function({
      Value<int> id,
      Value<String> color,
      Value<int> fixtureId,
      Value<int?> fixturePartId,
      Value<String?> size,
      Value<String?> maker,
    });

final class $$GelsTableReferences
    extends BaseReferences<_$AppDatabase, $GelsTable, Gel> {
  $$GelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) => db.fixtures
      .createAlias($_aliasNameGenerator(db.gels.fixtureId, db.fixtures.id));

  $$FixturesTableProcessedTableManager get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id')!;

    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FixturePartsTable _fixturePartIdTable(_$AppDatabase db) =>
      db.fixtureParts.createAlias(
        $_aliasNameGenerator(db.gels.fixturePartId, db.fixtureParts.id),
      );

  $$FixturePartsTableProcessedTableManager? get fixturePartId {
    final $_column = $_itemColumn<int>('fixture_part_id');
    if ($_column == null) return null;
    final manager = $$FixturePartsTableTableManager(
      $_db,
      $_db.fixtureParts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixturePartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GelsTableFilterComposer extends Composer<_$AppDatabase, $GelsTable> {
  $$GelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maker => $composableBuilder(
    column: $table.maker,
    builder: (column) => ColumnFilters(column),
  );

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturePartsTableFilterComposer get fixturePartId {
    final $$FixturePartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixturePartId,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableFilterComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GelsTableOrderingComposer extends Composer<_$AppDatabase, $GelsTable> {
  $$GelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maker => $composableBuilder(
    column: $table.maker,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturePartsTableOrderingComposer get fixturePartId {
    final $$FixturePartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixturePartId,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableOrderingComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GelsTable> {
  $$GelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get maker =>
      $composableBuilder(column: $table.maker, builder: (column) => column);

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturePartsTableAnnotationComposer get fixturePartId {
    final $$FixturePartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixturePartId,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GelsTable,
          Gel,
          $$GelsTableFilterComposer,
          $$GelsTableOrderingComposer,
          $$GelsTableAnnotationComposer,
          $$GelsTableCreateCompanionBuilder,
          $$GelsTableUpdateCompanionBuilder,
          (Gel, $$GelsTableReferences),
          Gel,
          PrefetchHooks Function({bool fixtureId, bool fixturePartId})
        > {
  $$GelsTableTableManager(_$AppDatabase db, $GelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> fixtureId = const Value.absent(),
                Value<int?> fixturePartId = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<String?> maker = const Value.absent(),
              }) => GelsCompanion(
                id: id,
                color: color,
                fixtureId: fixtureId,
                fixturePartId: fixturePartId,
                size: size,
                maker: maker,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String color,
                required int fixtureId,
                Value<int?> fixturePartId = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<String?> maker = const Value.absent(),
              }) => GelsCompanion.insert(
                id: id,
                color: color,
                fixtureId: fixtureId,
                fixturePartId: fixturePartId,
                size: size,
                maker: maker,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GelsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({fixtureId = false, fixturePartId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fixtureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixtureId,
                                referencedTable: $$GelsTableReferences
                                    ._fixtureIdTable(db),
                                referencedColumn: $$GelsTableReferences
                                    ._fixtureIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (fixturePartId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixturePartId,
                                referencedTable: $$GelsTableReferences
                                    ._fixturePartIdTable(db),
                                referencedColumn: $$GelsTableReferences
                                    ._fixturePartIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GelsTable,
      Gel,
      $$GelsTableFilterComposer,
      $$GelsTableOrderingComposer,
      $$GelsTableAnnotationComposer,
      $$GelsTableCreateCompanionBuilder,
      $$GelsTableUpdateCompanionBuilder,
      (Gel, $$GelsTableReferences),
      Gel,
      PrefetchHooks Function({bool fixtureId, bool fixturePartId})
    >;
typedef $$GobosTableCreateCompanionBuilder =
    GobosCompanion Function({
      Value<int> id,
      required String goboNumber,
      required int fixtureId,
      Value<int?> fixturePartId,
      Value<String?> size,
      Value<String?> maker,
    });
typedef $$GobosTableUpdateCompanionBuilder =
    GobosCompanion Function({
      Value<int> id,
      Value<String> goboNumber,
      Value<int> fixtureId,
      Value<int?> fixturePartId,
      Value<String?> size,
      Value<String?> maker,
    });

final class $$GobosTableReferences
    extends BaseReferences<_$AppDatabase, $GobosTable, Gobo> {
  $$GobosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) => db.fixtures
      .createAlias($_aliasNameGenerator(db.gobos.fixtureId, db.fixtures.id));

  $$FixturesTableProcessedTableManager get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id')!;

    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FixturePartsTable _fixturePartIdTable(_$AppDatabase db) =>
      db.fixtureParts.createAlias(
        $_aliasNameGenerator(db.gobos.fixturePartId, db.fixtureParts.id),
      );

  $$FixturePartsTableProcessedTableManager? get fixturePartId {
    final $_column = $_itemColumn<int>('fixture_part_id');
    if ($_column == null) return null;
    final manager = $$FixturePartsTableTableManager(
      $_db,
      $_db.fixtureParts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixturePartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GobosTableFilterComposer extends Composer<_$AppDatabase, $GobosTable> {
  $$GobosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goboNumber => $composableBuilder(
    column: $table.goboNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maker => $composableBuilder(
    column: $table.maker,
    builder: (column) => ColumnFilters(column),
  );

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturePartsTableFilterComposer get fixturePartId {
    final $$FixturePartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixturePartId,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableFilterComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GobosTableOrderingComposer
    extends Composer<_$AppDatabase, $GobosTable> {
  $$GobosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goboNumber => $composableBuilder(
    column: $table.goboNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maker => $composableBuilder(
    column: $table.maker,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturePartsTableOrderingComposer get fixturePartId {
    final $$FixturePartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixturePartId,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableOrderingComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GobosTableAnnotationComposer
    extends Composer<_$AppDatabase, $GobosTable> {
  $$GobosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goboNumber => $composableBuilder(
    column: $table.goboNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get maker =>
      $composableBuilder(column: $table.maker, builder: (column) => column);

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturePartsTableAnnotationComposer get fixturePartId {
    final $$FixturePartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixturePartId,
      referencedTable: $db.fixtureParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturePartsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtureParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GobosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GobosTable,
          Gobo,
          $$GobosTableFilterComposer,
          $$GobosTableOrderingComposer,
          $$GobosTableAnnotationComposer,
          $$GobosTableCreateCompanionBuilder,
          $$GobosTableUpdateCompanionBuilder,
          (Gobo, $$GobosTableReferences),
          Gobo,
          PrefetchHooks Function({bool fixtureId, bool fixturePartId})
        > {
  $$GobosTableTableManager(_$AppDatabase db, $GobosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GobosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GobosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GobosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> goboNumber = const Value.absent(),
                Value<int> fixtureId = const Value.absent(),
                Value<int?> fixturePartId = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<String?> maker = const Value.absent(),
              }) => GobosCompanion(
                id: id,
                goboNumber: goboNumber,
                fixtureId: fixtureId,
                fixturePartId: fixturePartId,
                size: size,
                maker: maker,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String goboNumber,
                required int fixtureId,
                Value<int?> fixturePartId = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<String?> maker = const Value.absent(),
              }) => GobosCompanion.insert(
                id: id,
                goboNumber: goboNumber,
                fixtureId: fixtureId,
                fixturePartId: fixturePartId,
                size: size,
                maker: maker,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GobosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({fixtureId = false, fixturePartId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fixtureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixtureId,
                                referencedTable: $$GobosTableReferences
                                    ._fixtureIdTable(db),
                                referencedColumn: $$GobosTableReferences
                                    ._fixtureIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (fixturePartId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixturePartId,
                                referencedTable: $$GobosTableReferences
                                    ._fixturePartIdTable(db),
                                referencedColumn: $$GobosTableReferences
                                    ._fixturePartIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GobosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GobosTable,
      Gobo,
      $$GobosTableFilterComposer,
      $$GobosTableOrderingComposer,
      $$GobosTableAnnotationComposer,
      $$GobosTableCreateCompanionBuilder,
      $$GobosTableUpdateCompanionBuilder,
      (Gobo, $$GobosTableReferences),
      Gobo,
      PrefetchHooks Function({bool fixtureId, bool fixturePartId})
    >;
typedef $$AccessoriesTableCreateCompanionBuilder =
    AccessoriesCompanion Function({
      Value<int> id,
      required String name,
      required int fixtureId,
    });
typedef $$AccessoriesTableUpdateCompanionBuilder =
    AccessoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> fixtureId,
    });

final class $$AccessoriesTableReferences
    extends BaseReferences<_$AppDatabase, $AccessoriesTable, Accessory> {
  $$AccessoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) =>
      db.fixtures.createAlias(
        $_aliasNameGenerator(db.accessories.fixtureId, db.fixtures.id),
      );

  $$FixturesTableProcessedTableManager get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id')!;

    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AccessoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccessoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccessoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccessoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccessoriesTable,
          Accessory,
          $$AccessoriesTableFilterComposer,
          $$AccessoriesTableOrderingComposer,
          $$AccessoriesTableAnnotationComposer,
          $$AccessoriesTableCreateCompanionBuilder,
          $$AccessoriesTableUpdateCompanionBuilder,
          (Accessory, $$AccessoriesTableReferences),
          Accessory,
          PrefetchHooks Function({bool fixtureId})
        > {
  $$AccessoriesTableTableManager(_$AppDatabase db, $AccessoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccessoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccessoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccessoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> fixtureId = const Value.absent(),
              }) => AccessoriesCompanion(
                id: id,
                name: name,
                fixtureId: fixtureId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int fixtureId,
              }) => AccessoriesCompanion.insert(
                id: id,
                name: name,
                fixtureId: fixtureId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccessoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fixtureId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fixtureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixtureId,
                                referencedTable: $$AccessoriesTableReferences
                                    ._fixtureIdTable(db),
                                referencedColumn: $$AccessoriesTableReferences
                                    ._fixtureIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AccessoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccessoriesTable,
      Accessory,
      $$AccessoriesTableFilterComposer,
      $$AccessoriesTableOrderingComposer,
      $$AccessoriesTableAnnotationComposer,
      $$AccessoriesTableCreateCompanionBuilder,
      $$AccessoriesTableUpdateCompanionBuilder,
      (Accessory, $$AccessoriesTableReferences),
      Accessory,
      PrefetchHooks Function({bool fixtureId})
    >;
typedef $$WorkNotesTableCreateCompanionBuilder =
    WorkNotesCompanion Function({
      Value<int> id,
      required String body,
      required String userId,
      required String timestamp,
      Value<int?> fixtureId,
      Value<String?> position,
    });
typedef $$WorkNotesTableUpdateCompanionBuilder =
    WorkNotesCompanion Function({
      Value<int> id,
      Value<String> body,
      Value<String> userId,
      Value<String> timestamp,
      Value<int?> fixtureId,
      Value<String?> position,
    });

final class $$WorkNotesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkNotesTable, WorkNote> {
  $$WorkNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) =>
      db.fixtures.createAlias(
        $_aliasNameGenerator(db.workNotes.fixtureId, db.fixtures.id),
      );

  $$FixturesTableProcessedTableManager? get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id');
    if ($_column == null) return null;
    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkNotesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkNotesTable> {
  $$WorkNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkNotesTable> {
  $$WorkNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkNotesTable> {
  $$WorkNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkNotesTable,
          WorkNote,
          $$WorkNotesTableFilterComposer,
          $$WorkNotesTableOrderingComposer,
          $$WorkNotesTableAnnotationComposer,
          $$WorkNotesTableCreateCompanionBuilder,
          $$WorkNotesTableUpdateCompanionBuilder,
          (WorkNote, $$WorkNotesTableReferences),
          WorkNote,
          PrefetchHooks Function({bool fixtureId})
        > {
  $$WorkNotesTableTableManager(_$AppDatabase db, $WorkNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<int?> fixtureId = const Value.absent(),
                Value<String?> position = const Value.absent(),
              }) => WorkNotesCompanion(
                id: id,
                body: body,
                userId: userId,
                timestamp: timestamp,
                fixtureId: fixtureId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String body,
                required String userId,
                required String timestamp,
                Value<int?> fixtureId = const Value.absent(),
                Value<String?> position = const Value.absent(),
              }) => WorkNotesCompanion.insert(
                id: id,
                body: body,
                userId: userId,
                timestamp: timestamp,
                fixtureId: fixtureId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fixtureId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fixtureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixtureId,
                                referencedTable: $$WorkNotesTableReferences
                                    ._fixtureIdTable(db),
                                referencedColumn: $$WorkNotesTableReferences
                                    ._fixtureIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkNotesTable,
      WorkNote,
      $$WorkNotesTableFilterComposer,
      $$WorkNotesTableOrderingComposer,
      $$WorkNotesTableAnnotationComposer,
      $$WorkNotesTableCreateCompanionBuilder,
      $$WorkNotesTableUpdateCompanionBuilder,
      (WorkNote, $$WorkNotesTableReferences),
      WorkNote,
      PrefetchHooks Function({bool fixtureId})
    >;
typedef $$MaintenanceLogTableCreateCompanionBuilder =
    MaintenanceLogCompanion Function({
      Value<int> id,
      required int fixtureId,
      required String description,
      required String userId,
      required String timestamp,
      Value<int> resolved,
    });
typedef $$MaintenanceLogTableUpdateCompanionBuilder =
    MaintenanceLogCompanion Function({
      Value<int> id,
      Value<int> fixtureId,
      Value<String> description,
      Value<String> userId,
      Value<String> timestamp,
      Value<int> resolved,
    });

final class $$MaintenanceLogTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceLogTable,
          MaintenanceLogData
        > {
  $$MaintenanceLogTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) =>
      db.fixtures.createAlias(
        $_aliasNameGenerator(db.maintenanceLog.fixtureId, db.fixtures.id),
      );

  $$FixturesTableProcessedTableManager get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id')!;

    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceLogTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceLogTable> {
  $$MaintenanceLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceLogTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceLogTable> {
  $$MaintenanceLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceLogTable> {
  $$MaintenanceLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceLogTable,
          MaintenanceLogData,
          $$MaintenanceLogTableFilterComposer,
          $$MaintenanceLogTableOrderingComposer,
          $$MaintenanceLogTableAnnotationComposer,
          $$MaintenanceLogTableCreateCompanionBuilder,
          $$MaintenanceLogTableUpdateCompanionBuilder,
          (MaintenanceLogData, $$MaintenanceLogTableReferences),
          MaintenanceLogData,
          PrefetchHooks Function({bool fixtureId})
        > {
  $$MaintenanceLogTableTableManager(
    _$AppDatabase db,
    $MaintenanceLogTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fixtureId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<int> resolved = const Value.absent(),
              }) => MaintenanceLogCompanion(
                id: id,
                fixtureId: fixtureId,
                description: description,
                userId: userId,
                timestamp: timestamp,
                resolved: resolved,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fixtureId,
                required String description,
                required String userId,
                required String timestamp,
                Value<int> resolved = const Value.absent(),
              }) => MaintenanceLogCompanion.insert(
                id: id,
                fixtureId: fixtureId,
                description: description,
                userId: userId,
                timestamp: timestamp,
                resolved: resolved,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fixtureId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fixtureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixtureId,
                                referencedTable: $$MaintenanceLogTableReferences
                                    ._fixtureIdTable(db),
                                referencedColumn:
                                    $$MaintenanceLogTableReferences
                                        ._fixtureIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceLogTable,
      MaintenanceLogData,
      $$MaintenanceLogTableFilterComposer,
      $$MaintenanceLogTableOrderingComposer,
      $$MaintenanceLogTableAnnotationComposer,
      $$MaintenanceLogTableCreateCompanionBuilder,
      $$MaintenanceLogTableUpdateCompanionBuilder,
      (MaintenanceLogData, $$MaintenanceLogTableReferences),
      MaintenanceLogData,
      PrefetchHooks Function({bool fixtureId})
    >;
typedef $$CustomFieldsTableCreateCompanionBuilder =
    CustomFieldsCompanion Function({
      Value<int> id,
      required String name,
      required String dataType,
      Value<int> displayOrder,
    });
typedef $$CustomFieldsTableUpdateCompanionBuilder =
    CustomFieldsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> dataType,
      Value<int> displayOrder,
    });

final class $$CustomFieldsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomFieldsTable, CustomField> {
  $$CustomFieldsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomFieldValuesTable, List<CustomFieldValue>>
  _customFieldValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customFieldValues,
        aliasName: $_aliasNameGenerator(
          db.customFields.id,
          db.customFieldValues.customFieldId,
        ),
      );

  $$CustomFieldValuesTableProcessedTableManager get customFieldValuesRefs {
    final manager = $$CustomFieldValuesTableTableManager(
      $_db,
      $_db.customFieldValues,
    ).filter((f) => f.customFieldId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customFieldValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFieldsTable> {
  $$CustomFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customFieldValuesRefs(
    Expression<bool> Function($$CustomFieldValuesTableFilterComposer f) f,
  ) {
    final $$CustomFieldValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customFieldValues,
      getReferencedColumn: (t) => t.customFieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomFieldValuesTableFilterComposer(
            $db: $db,
            $table: $db.customFieldValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFieldsTable> {
  $$CustomFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFieldsTable> {
  $$CustomFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  Expression<T> customFieldValuesRefs<T extends Object>(
    Expression<T> Function($$CustomFieldValuesTableAnnotationComposer a) f,
  ) {
    final $$CustomFieldValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customFieldValues,
          getReferencedColumn: (t) => t.customFieldId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomFieldValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.customFieldValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CustomFieldsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFieldsTable,
          CustomField,
          $$CustomFieldsTableFilterComposer,
          $$CustomFieldsTableOrderingComposer,
          $$CustomFieldsTableAnnotationComposer,
          $$CustomFieldsTableCreateCompanionBuilder,
          $$CustomFieldsTableUpdateCompanionBuilder,
          (CustomField, $$CustomFieldsTableReferences),
          CustomField,
          PrefetchHooks Function({bool customFieldValuesRefs})
        > {
  $$CustomFieldsTableTableManager(_$AppDatabase db, $CustomFieldsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dataType = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
              }) => CustomFieldsCompanion(
                id: id,
                name: name,
                dataType: dataType,
                displayOrder: displayOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String dataType,
                Value<int> displayOrder = const Value.absent(),
              }) => CustomFieldsCompanion.insert(
                id: id,
                name: name,
                dataType: dataType,
                displayOrder: displayOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomFieldsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customFieldValuesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customFieldValuesRefs) db.customFieldValues,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customFieldValuesRefs)
                    await $_getPrefetchedData<
                      CustomField,
                      $CustomFieldsTable,
                      CustomFieldValue
                    >(
                      currentTable: table,
                      referencedTable: $$CustomFieldsTableReferences
                          ._customFieldValuesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomFieldsTableReferences(
                            db,
                            table,
                            p0,
                          ).customFieldValuesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.customFieldId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFieldsTable,
      CustomField,
      $$CustomFieldsTableFilterComposer,
      $$CustomFieldsTableOrderingComposer,
      $$CustomFieldsTableAnnotationComposer,
      $$CustomFieldsTableCreateCompanionBuilder,
      $$CustomFieldsTableUpdateCompanionBuilder,
      (CustomField, $$CustomFieldsTableReferences),
      CustomField,
      PrefetchHooks Function({bool customFieldValuesRefs})
    >;
typedef $$CustomFieldValuesTableCreateCompanionBuilder =
    CustomFieldValuesCompanion Function({
      Value<int> id,
      required int fixtureId,
      required int customFieldId,
      Value<String?> value,
    });
typedef $$CustomFieldValuesTableUpdateCompanionBuilder =
    CustomFieldValuesCompanion Function({
      Value<int> id,
      Value<int> fixtureId,
      Value<int> customFieldId,
      Value<String?> value,
    });

final class $$CustomFieldValuesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomFieldValuesTable,
          CustomFieldValue
        > {
  $$CustomFieldValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) =>
      db.fixtures.createAlias(
        $_aliasNameGenerator(db.customFieldValues.fixtureId, db.fixtures.id),
      );

  $$FixturesTableProcessedTableManager get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id')!;

    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomFieldsTable _customFieldIdTable(_$AppDatabase db) =>
      db.customFields.createAlias(
        $_aliasNameGenerator(
          db.customFieldValues.customFieldId,
          db.customFields.id,
        ),
      );

  $$CustomFieldsTableProcessedTableManager get customFieldId {
    final $_column = $_itemColumn<int>('custom_field_id')!;

    final manager = $$CustomFieldsTableTableManager(
      $_db,
      $_db.customFields,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customFieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomFieldValuesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFieldValuesTable> {
  $$CustomFieldValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomFieldsTableFilterComposer get customFieldId {
    final $$CustomFieldsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customFieldId,
      referencedTable: $db.customFields,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomFieldsTableFilterComposer(
            $db: $db,
            $table: $db.customFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomFieldValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFieldValuesTable> {
  $$CustomFieldValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomFieldsTableOrderingComposer get customFieldId {
    final $$CustomFieldsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customFieldId,
      referencedTable: $db.customFields,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomFieldsTableOrderingComposer(
            $db: $db,
            $table: $db.customFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomFieldValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFieldValuesTable> {
  $$CustomFieldValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomFieldsTableAnnotationComposer get customFieldId {
    final $$CustomFieldsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customFieldId,
      referencedTable: $db.customFields,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomFieldsTableAnnotationComposer(
            $db: $db,
            $table: $db.customFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomFieldValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFieldValuesTable,
          CustomFieldValue,
          $$CustomFieldValuesTableFilterComposer,
          $$CustomFieldValuesTableOrderingComposer,
          $$CustomFieldValuesTableAnnotationComposer,
          $$CustomFieldValuesTableCreateCompanionBuilder,
          $$CustomFieldValuesTableUpdateCompanionBuilder,
          (CustomFieldValue, $$CustomFieldValuesTableReferences),
          CustomFieldValue,
          PrefetchHooks Function({bool fixtureId, bool customFieldId})
        > {
  $$CustomFieldValuesTableTableManager(
    _$AppDatabase db,
    $CustomFieldValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFieldValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFieldValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFieldValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fixtureId = const Value.absent(),
                Value<int> customFieldId = const Value.absent(),
                Value<String?> value = const Value.absent(),
              }) => CustomFieldValuesCompanion(
                id: id,
                fixtureId: fixtureId,
                customFieldId: customFieldId,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fixtureId,
                required int customFieldId,
                Value<String?> value = const Value.absent(),
              }) => CustomFieldValuesCompanion.insert(
                id: id,
                fixtureId: fixtureId,
                customFieldId: customFieldId,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomFieldValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fixtureId = false, customFieldId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fixtureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixtureId,
                                referencedTable:
                                    $$CustomFieldValuesTableReferences
                                        ._fixtureIdTable(db),
                                referencedColumn:
                                    $$CustomFieldValuesTableReferences
                                        ._fixtureIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (customFieldId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customFieldId,
                                referencedTable:
                                    $$CustomFieldValuesTableReferences
                                        ._customFieldIdTable(db),
                                referencedColumn:
                                    $$CustomFieldValuesTableReferences
                                        ._customFieldIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomFieldValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFieldValuesTable,
      CustomFieldValue,
      $$CustomFieldValuesTableFilterComposer,
      $$CustomFieldValuesTableOrderingComposer,
      $$CustomFieldValuesTableAnnotationComposer,
      $$CustomFieldValuesTableCreateCompanionBuilder,
      $$CustomFieldValuesTableUpdateCompanionBuilder,
      (CustomFieldValue, $$CustomFieldValuesTableReferences),
      CustomFieldValue,
      PrefetchHooks Function({bool fixtureId, bool customFieldId})
    >;
typedef $$ReportsTableCreateCompanionBuilder =
    ReportsCompanion Function({
      Value<int> id,
      required String name,
      required String templateJson,
      Value<int> isSystem,
    });
typedef $$ReportsTableUpdateCompanionBuilder =
    ReportsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> templateJson,
      Value<int> isSystem,
    });

class $$ReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateJson => $composableBuilder(
    column: $table.templateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateJson => $composableBuilder(
    column: $table.templateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get templateJson => $composableBuilder(
    column: $table.templateJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);
}

class $$ReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportsTable,
          Report,
          $$ReportsTableFilterComposer,
          $$ReportsTableOrderingComposer,
          $$ReportsTableAnnotationComposer,
          $$ReportsTableCreateCompanionBuilder,
          $$ReportsTableUpdateCompanionBuilder,
          (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
          Report,
          PrefetchHooks Function()
        > {
  $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> templateJson = const Value.absent(),
                Value<int> isSystem = const Value.absent(),
              }) => ReportsCompanion(
                id: id,
                name: name,
                templateJson: templateJson,
                isSystem: isSystem,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String templateJson,
                Value<int> isSystem = const Value.absent(),
              }) => ReportsCompanion.insert(
                id: id,
                name: name,
                templateJson: templateJson,
                isSystem: isSystem,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportsTable,
      Report,
      $$ReportsTableFilterComposer,
      $$ReportsTableOrderingComposer,
      $$ReportsTableAnnotationComposer,
      $$ReportsTableCreateCompanionBuilder,
      $$ReportsTableUpdateCompanionBuilder,
      (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
      Report,
      PrefetchHooks Function()
    >;
typedef $$CommitsTableCreateCompanionBuilder =
    CommitsCompanion Function({
      Value<int> id,
      required String userId,
      required String timestamp,
      Value<String?> notes,
    });
typedef $$CommitsTableUpdateCompanionBuilder =
    CommitsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> timestamp,
      Value<String?> notes,
    });

final class $$CommitsTableReferences
    extends BaseReferences<_$AppDatabase, $CommitsTable, Commit> {
  $$CommitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RevisionsTable, List<Revision>>
  _revisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.revisions,
    aliasName: $_aliasNameGenerator(db.commits.id, db.revisions.commitId),
  );

  $$RevisionsTableProcessedTableManager get revisionsRefs {
    final manager = $$RevisionsTableTableManager(
      $_db,
      $_db.revisions,
    ).filter((f) => f.commitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_revisionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CommitsTableFilterComposer
    extends Composer<_$AppDatabase, $CommitsTable> {
  $$CommitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> revisionsRefs(
    Expression<bool> Function($$RevisionsTableFilterComposer f) f,
  ) {
    final $$RevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisions,
      getReferencedColumn: (t) => t.commitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisionsTableFilterComposer(
            $db: $db,
            $table: $db.revisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommitsTable> {
  $$CommitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommitsTable> {
  $$CommitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> revisionsRefs<T extends Object>(
    Expression<T> Function($$RevisionsTableAnnotationComposer a) f,
  ) {
    final $$RevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.revisions,
      getReferencedColumn: (t) => t.commitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.revisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommitsTable,
          Commit,
          $$CommitsTableFilterComposer,
          $$CommitsTableOrderingComposer,
          $$CommitsTableAnnotationComposer,
          $$CommitsTableCreateCompanionBuilder,
          $$CommitsTableUpdateCompanionBuilder,
          (Commit, $$CommitsTableReferences),
          Commit,
          PrefetchHooks Function({bool revisionsRefs})
        > {
  $$CommitsTableTableManager(_$AppDatabase db, $CommitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CommitsCompanion(
                id: id,
                userId: userId,
                timestamp: timestamp,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String timestamp,
                Value<String?> notes = const Value.absent(),
              }) => CommitsCompanion.insert(
                id: id,
                userId: userId,
                timestamp: timestamp,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({revisionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (revisionsRefs) db.revisions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (revisionsRefs)
                    await $_getPrefetchedData<Commit, $CommitsTable, Revision>(
                      currentTable: table,
                      referencedTable: $$CommitsTableReferences
                          ._revisionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CommitsTableReferences(db, table, p0).revisionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.commitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CommitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommitsTable,
      Commit,
      $$CommitsTableFilterComposer,
      $$CommitsTableOrderingComposer,
      $$CommitsTableAnnotationComposer,
      $$CommitsTableCreateCompanionBuilder,
      $$CommitsTableUpdateCompanionBuilder,
      (Commit, $$CommitsTableReferences),
      Commit,
      PrefetchHooks Function({bool revisionsRefs})
    >;
typedef $$RevisionsTableCreateCompanionBuilder =
    RevisionsCompanion Function({
      Value<int> id,
      required String operation,
      required String targetTable,
      Value<int?> targetId,
      Value<String?> fieldName,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String?> batchId,
      required String userId,
      required String timestamp,
      Value<String> status,
      Value<int?> commitId,
    });
typedef $$RevisionsTableUpdateCompanionBuilder =
    RevisionsCompanion Function({
      Value<int> id,
      Value<String> operation,
      Value<String> targetTable,
      Value<int?> targetId,
      Value<String?> fieldName,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String?> batchId,
      Value<String> userId,
      Value<String> timestamp,
      Value<String> status,
      Value<int?> commitId,
    });

final class $$RevisionsTableReferences
    extends BaseReferences<_$AppDatabase, $RevisionsTable, Revision> {
  $$RevisionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CommitsTable _commitIdTable(_$AppDatabase db) => db.commits
      .createAlias($_aliasNameGenerator(db.revisions.commitId, db.commits.id));

  $$CommitsTableProcessedTableManager? get commitId {
    final $_column = $_itemColumn<int>('commit_id');
    if ($_column == null) return null;
    final manager = $$CommitsTableTableManager(
      $_db,
      $_db.commits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_commitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $RevisionsTable> {
  $$RevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$CommitsTableFilterComposer get commitId {
    final $$CommitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitId,
      referencedTable: $db.commits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitsTableFilterComposer(
            $db: $db,
            $table: $db.commits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RevisionsTable> {
  $$RevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$CommitsTableOrderingComposer get commitId {
    final $$CommitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitId,
      referencedTable: $db.commits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitsTableOrderingComposer(
            $db: $db,
            $table: $db.commits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevisionsTable> {
  $$RevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get fieldName =>
      $composableBuilder(column: $table.fieldName, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$CommitsTableAnnotationComposer get commitId {
    final $$CommitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitId,
      referencedTable: $db.commits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitsTableAnnotationComposer(
            $db: $db,
            $table: $db.commits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevisionsTable,
          Revision,
          $$RevisionsTableFilterComposer,
          $$RevisionsTableOrderingComposer,
          $$RevisionsTableAnnotationComposer,
          $$RevisionsTableCreateCompanionBuilder,
          $$RevisionsTableUpdateCompanionBuilder,
          (Revision, $$RevisionsTableReferences),
          Revision,
          PrefetchHooks Function({bool commitId})
        > {
  $$RevisionsTableTableManager(_$AppDatabase db, $RevisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<int?> targetId = const Value.absent(),
                Value<String?> fieldName = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> commitId = const Value.absent(),
              }) => RevisionsCompanion(
                id: id,
                operation: operation,
                targetTable: targetTable,
                targetId: targetId,
                fieldName: fieldName,
                oldValue: oldValue,
                newValue: newValue,
                batchId: batchId,
                userId: userId,
                timestamp: timestamp,
                status: status,
                commitId: commitId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operation,
                required String targetTable,
                Value<int?> targetId = const Value.absent(),
                Value<String?> fieldName = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                required String userId,
                required String timestamp,
                Value<String> status = const Value.absent(),
                Value<int?> commitId = const Value.absent(),
              }) => RevisionsCompanion.insert(
                id: id,
                operation: operation,
                targetTable: targetTable,
                targetId: targetId,
                fieldName: fieldName,
                oldValue: oldValue,
                newValue: newValue,
                batchId: batchId,
                userId: userId,
                timestamp: timestamp,
                status: status,
                commitId: commitId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({commitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (commitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.commitId,
                                referencedTable: $$RevisionsTableReferences
                                    ._commitIdTable(db),
                                referencedColumn: $$RevisionsTableReferences
                                    ._commitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevisionsTable,
      Revision,
      $$RevisionsTableFilterComposer,
      $$RevisionsTableOrderingComposer,
      $$RevisionsTableAnnotationComposer,
      $$RevisionsTableCreateCompanionBuilder,
      $$RevisionsTableUpdateCompanionBuilder,
      (Revision, $$RevisionsTableReferences),
      Revision,
      PrefetchHooks Function({bool commitId})
    >;
typedef $$PositionGroupsTableCreateCompanionBuilder =
    PositionGroupsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sortOrder,
      Value<String?> color,
    });
typedef $$PositionGroupsTableUpdateCompanionBuilder =
    PositionGroupsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sortOrder,
      Value<String?> color,
    });

class $$PositionGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $PositionGroupsTable> {
  $$PositionGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PositionGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $PositionGroupsTable> {
  $$PositionGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PositionGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PositionGroupsTable> {
  $$PositionGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$PositionGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PositionGroupsTable,
          PositionGroup,
          $$PositionGroupsTableFilterComposer,
          $$PositionGroupsTableOrderingComposer,
          $$PositionGroupsTableAnnotationComposer,
          $$PositionGroupsTableCreateCompanionBuilder,
          $$PositionGroupsTableUpdateCompanionBuilder,
          (
            PositionGroup,
            BaseReferences<_$AppDatabase, $PositionGroupsTable, PositionGroup>,
          ),
          PositionGroup,
          PrefetchHooks Function()
        > {
  $$PositionGroupsTableTableManager(
    _$AppDatabase db,
    $PositionGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PositionGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PositionGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PositionGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> color = const Value.absent(),
              }) => PositionGroupsCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                color: color,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> color = const Value.absent(),
              }) => PositionGroupsCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                color: color,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PositionGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PositionGroupsTable,
      PositionGroup,
      $$PositionGroupsTableFilterComposer,
      $$PositionGroupsTableOrderingComposer,
      $$PositionGroupsTableAnnotationComposer,
      $$PositionGroupsTableCreateCompanionBuilder,
      $$PositionGroupsTableUpdateCompanionBuilder,
      (
        PositionGroup,
        BaseReferences<_$AppDatabase, $PositionGroupsTable, PositionGroup>,
      ),
      PositionGroup,
      PrefetchHooks Function()
    >;
typedef $$RoleContactsTableCreateCompanionBuilder =
    RoleContactsCompanion Function({
      Value<int> id,
      required String roleKey,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> mailingAddress,
      Value<String?> paperTekUserId,
    });
typedef $$RoleContactsTableUpdateCompanionBuilder =
    RoleContactsCompanion Function({
      Value<int> id,
      Value<String> roleKey,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> mailingAddress,
      Value<String?> paperTekUserId,
    });

class $$RoleContactsTableFilterComposer
    extends Composer<_$AppDatabase, $RoleContactsTable> {
  $$RoleContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleKey => $composableBuilder(
    column: $table.roleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mailingAddress => $composableBuilder(
    column: $table.mailingAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paperTekUserId => $composableBuilder(
    column: $table.paperTekUserId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoleContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoleContactsTable> {
  $$RoleContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleKey => $composableBuilder(
    column: $table.roleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mailingAddress => $composableBuilder(
    column: $table.mailingAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paperTekUserId => $composableBuilder(
    column: $table.paperTekUserId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoleContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoleContactsTable> {
  $$RoleContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roleKey =>
      $composableBuilder(column: $table.roleKey, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get mailingAddress => $composableBuilder(
    column: $table.mailingAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paperTekUserId => $composableBuilder(
    column: $table.paperTekUserId,
    builder: (column) => column,
  );
}

class $$RoleContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoleContactsTable,
          RoleContact,
          $$RoleContactsTableFilterComposer,
          $$RoleContactsTableOrderingComposer,
          $$RoleContactsTableAnnotationComposer,
          $$RoleContactsTableCreateCompanionBuilder,
          $$RoleContactsTableUpdateCompanionBuilder,
          (
            RoleContact,
            BaseReferences<_$AppDatabase, $RoleContactsTable, RoleContact>,
          ),
          RoleContact,
          PrefetchHooks Function()
        > {
  $$RoleContactsTableTableManager(_$AppDatabase db, $RoleContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoleContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoleContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoleContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> roleKey = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> mailingAddress = const Value.absent(),
                Value<String?> paperTekUserId = const Value.absent(),
              }) => RoleContactsCompanion(
                id: id,
                roleKey: roleKey,
                email: email,
                phone: phone,
                mailingAddress: mailingAddress,
                paperTekUserId: paperTekUserId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String roleKey,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> mailingAddress = const Value.absent(),
                Value<String?> paperTekUserId = const Value.absent(),
              }) => RoleContactsCompanion.insert(
                id: id,
                roleKey: roleKey,
                email: email,
                phone: phone,
                mailingAddress: mailingAddress,
                paperTekUserId: paperTekUserId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoleContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoleContactsTable,
      RoleContact,
      $$RoleContactsTableFilterComposer,
      $$RoleContactsTableOrderingComposer,
      $$RoleContactsTableAnnotationComposer,
      $$RoleContactsTableCreateCompanionBuilder,
      $$RoleContactsTableUpdateCompanionBuilder,
      (
        RoleContact,
        BaseReferences<_$AppDatabase, $RoleContactsTable, RoleContact>,
      ),
      RoleContact,
      PrefetchHooks Function()
    >;
typedef $$SpreadsheetViewPresetsTableCreateCompanionBuilder =
    SpreadsheetViewPresetsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> isSystem,
      required String createdAt,
      required String updatedAt,
      required String presetJson,
    });
typedef $$SpreadsheetViewPresetsTableUpdateCompanionBuilder =
    SpreadsheetViewPresetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> isSystem,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> presetJson,
    });

class $$SpreadsheetViewPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $SpreadsheetViewPresetsTable> {
  $$SpreadsheetViewPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetJson => $composableBuilder(
    column: $table.presetJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpreadsheetViewPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpreadsheetViewPresetsTable> {
  $$SpreadsheetViewPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetJson => $composableBuilder(
    column: $table.presetJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpreadsheetViewPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpreadsheetViewPresetsTable> {
  $$SpreadsheetViewPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get presetJson => $composableBuilder(
    column: $table.presetJson,
    builder: (column) => column,
  );
}

class $$SpreadsheetViewPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpreadsheetViewPresetsTable,
          SpreadsheetViewPreset,
          $$SpreadsheetViewPresetsTableFilterComposer,
          $$SpreadsheetViewPresetsTableOrderingComposer,
          $$SpreadsheetViewPresetsTableAnnotationComposer,
          $$SpreadsheetViewPresetsTableCreateCompanionBuilder,
          $$SpreadsheetViewPresetsTableUpdateCompanionBuilder,
          (
            SpreadsheetViewPreset,
            BaseReferences<
              _$AppDatabase,
              $SpreadsheetViewPresetsTable,
              SpreadsheetViewPreset
            >,
          ),
          SpreadsheetViewPreset,
          PrefetchHooks Function()
        > {
  $$SpreadsheetViewPresetsTableTableManager(
    _$AppDatabase db,
    $SpreadsheetViewPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpreadsheetViewPresetsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SpreadsheetViewPresetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SpreadsheetViewPresetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> isSystem = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> presetJson = const Value.absent(),
              }) => SpreadsheetViewPresetsCompanion(
                id: id,
                name: name,
                isSystem: isSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                presetJson: presetJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> isSystem = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                required String presetJson,
              }) => SpreadsheetViewPresetsCompanion.insert(
                id: id,
                name: name,
                isSystem: isSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                presetJson: presetJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpreadsheetViewPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpreadsheetViewPresetsTable,
      SpreadsheetViewPreset,
      $$SpreadsheetViewPresetsTableFilterComposer,
      $$SpreadsheetViewPresetsTableOrderingComposer,
      $$SpreadsheetViewPresetsTableAnnotationComposer,
      $$SpreadsheetViewPresetsTableCreateCompanionBuilder,
      $$SpreadsheetViewPresetsTableUpdateCompanionBuilder,
      (
        SpreadsheetViewPreset,
        BaseReferences<
          _$AppDatabase,
          $SpreadsheetViewPresetsTable,
          SpreadsheetViewPreset
        >,
      ),
      SpreadsheetViewPreset,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      required String type,
      required String body,
      required String createdBy,
      required String createdAt,
      Value<int> completed,
      Value<String?> completedAt,
      Value<String?> completedBy,
      Value<int> elevated,
      Value<int?> fixtureTypeId,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> body,
      Value<String> createdBy,
      Value<String> createdAt,
      Value<int> completed,
      Value<String?> completedAt,
      Value<String?> completedBy,
      Value<int> elevated,
      Value<int?> fixtureTypeId,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FixtureTypesTable _fixtureTypeIdTable(_$AppDatabase db) =>
      db.fixtureTypes.createAlias(
        $_aliasNameGenerator(db.notes.fixtureTypeId, db.fixtureTypes.id),
      );

  $$FixtureTypesTableProcessedTableManager? get fixtureTypeId {
    final $_column = $_itemColumn<int>('fixture_type_id');
    if ($_column == null) return null;
    final manager = $$FixtureTypesTableTableManager(
      $_db,
      $_db.fixtureTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NoteActionsTable, List<NoteAction>>
  _noteActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteActions,
    aliasName: $_aliasNameGenerator(db.notes.id, db.noteActions.noteId),
  );

  $$NoteActionsTableProcessedTableManager get noteActionsRefs {
    final manager = $$NoteActionsTableTableManager(
      $_db,
      $_db.noteActions,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteFixturesTable, List<NoteFixture>>
  _noteFixturesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteFixtures,
    aliasName: $_aliasNameGenerator(db.notes.id, db.noteFixtures.noteId),
  );

  $$NoteFixturesTableProcessedTableManager get noteFixturesRefs {
    final manager = $$NoteFixturesTableTableManager(
      $_db,
      $_db.noteFixtures,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteFixturesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotePositionsTable, List<NotePosition>>
  _notePositionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notePositions,
    aliasName: $_aliasNameGenerator(db.notes.id, db.notePositions.noteId),
  );

  $$NotePositionsTableProcessedTableManager get notePositionsRefs {
    final manager = $$NotePositionsTableTableManager(
      $_db,
      $_db.notePositions,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notePositionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedBy => $composableBuilder(
    column: $table.completedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elevated => $composableBuilder(
    column: $table.elevated,
    builder: (column) => ColumnFilters(column),
  );

  $$FixtureTypesTableFilterComposer get fixtureTypeId {
    final $$FixtureTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureTypeId,
      referencedTable: $db.fixtureTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureTypesTableFilterComposer(
            $db: $db,
            $table: $db.fixtureTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> noteActionsRefs(
    Expression<bool> Function($$NoteActionsTableFilterComposer f) f,
  ) {
    final $$NoteActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteActions,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteActionsTableFilterComposer(
            $db: $db,
            $table: $db.noteActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteFixturesRefs(
    Expression<bool> Function($$NoteFixturesTableFilterComposer f) f,
  ) {
    final $$NoteFixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFixtures,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFixturesTableFilterComposer(
            $db: $db,
            $table: $db.noteFixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notePositionsRefs(
    Expression<bool> Function($$NotePositionsTableFilterComposer f) f,
  ) {
    final $$NotePositionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePositions,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePositionsTableFilterComposer(
            $db: $db,
            $table: $db.notePositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedBy => $composableBuilder(
    column: $table.completedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elevated => $composableBuilder(
    column: $table.elevated,
    builder: (column) => ColumnOrderings(column),
  );

  $$FixtureTypesTableOrderingComposer get fixtureTypeId {
    final $$FixtureTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureTypeId,
      referencedTable: $db.fixtureTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureTypesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtureTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedBy => $composableBuilder(
    column: $table.completedBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elevated =>
      $composableBuilder(column: $table.elevated, builder: (column) => column);

  $$FixtureTypesTableAnnotationComposer get fixtureTypeId {
    final $$FixtureTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureTypeId,
      referencedTable: $db.fixtureTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixtureTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtureTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> noteActionsRefs<T extends Object>(
    Expression<T> Function($$NoteActionsTableAnnotationComposer a) f,
  ) {
    final $$NoteActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteActions,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteFixturesRefs<T extends Object>(
    Expression<T> Function($$NoteFixturesTableAnnotationComposer a) f,
  ) {
    final $$NoteFixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFixtures,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.noteFixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notePositionsRefs<T extends Object>(
    Expression<T> Function($$NotePositionsTableAnnotationComposer a) f,
  ) {
    final $$NotePositionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePositions,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePositionsTableAnnotationComposer(
            $db: $db,
            $table: $db.notePositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({
            bool fixtureTypeId,
            bool noteActionsRefs,
            bool noteFixturesRefs,
            bool notePositionsRefs,
          })
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> completed = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<String?> completedBy = const Value.absent(),
                Value<int> elevated = const Value.absent(),
                Value<int?> fixtureTypeId = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                type: type,
                body: body,
                createdBy: createdBy,
                createdAt: createdAt,
                completed: completed,
                completedAt: completedAt,
                completedBy: completedBy,
                elevated: elevated,
                fixtureTypeId: fixtureTypeId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String body,
                required String createdBy,
                required String createdAt,
                Value<int> completed = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
                Value<String?> completedBy = const Value.absent(),
                Value<int> elevated = const Value.absent(),
                Value<int?> fixtureTypeId = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                type: type,
                body: body,
                createdBy: createdBy,
                createdAt: createdAt,
                completed: completed,
                completedAt: completedAt,
                completedBy: completedBy,
                elevated: elevated,
                fixtureTypeId: fixtureTypeId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fixtureTypeId = false,
                noteActionsRefs = false,
                noteFixturesRefs = false,
                notePositionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteActionsRefs) db.noteActions,
                    if (noteFixturesRefs) db.noteFixtures,
                    if (notePositionsRefs) db.notePositions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fixtureTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fixtureTypeId,
                                    referencedTable: $$NotesTableReferences
                                        ._fixtureTypeIdTable(db),
                                    referencedColumn: $$NotesTableReferences
                                        ._fixtureTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteActionsRefs)
                        await $_getPrefetchedData<
                          Note,
                          $NotesTable,
                          NoteAction
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.noteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteFixturesRefs)
                        await $_getPrefetchedData<
                          Note,
                          $NotesTable,
                          NoteFixture
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteFixturesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteFixturesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.noteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notePositionsRefs)
                        await $_getPrefetchedData<
                          Note,
                          $NotesTable,
                          NotePosition
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._notePositionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).notePositionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.noteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({
        bool fixtureTypeId,
        bool noteActionsRefs,
        bool noteFixturesRefs,
        bool notePositionsRefs,
      })
    >;
typedef $$NoteActionsTableCreateCompanionBuilder =
    NoteActionsCompanion Function({
      Value<int> id,
      required int noteId,
      required String body,
      required String userId,
      required String timestamp,
    });
typedef $$NoteActionsTableUpdateCompanionBuilder =
    NoteActionsCompanion Function({
      Value<int> id,
      Value<int> noteId,
      Value<String> body,
      Value<String> userId,
      Value<String> timestamp,
    });

final class $$NoteActionsTableReferences
    extends BaseReferences<_$AppDatabase, $NoteActionsTable, NoteAction> {
  $$NoteActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) => db.notes.createAlias(
    $_aliasNameGenerator(db.noteActions.noteId, db.notes.id),
  );

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteActionsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteActionsTable> {
  $$NoteActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteActionsTable> {
  $$NoteActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteActionsTable> {
  $$NoteActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteActionsTable,
          NoteAction,
          $$NoteActionsTableFilterComposer,
          $$NoteActionsTableOrderingComposer,
          $$NoteActionsTableAnnotationComposer,
          $$NoteActionsTableCreateCompanionBuilder,
          $$NoteActionsTableUpdateCompanionBuilder,
          (NoteAction, $$NoteActionsTableReferences),
          NoteAction,
          PrefetchHooks Function({bool noteId})
        > {
  $$NoteActionsTableTableManager(_$AppDatabase db, $NoteActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> noteId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
              }) => NoteActionsCompanion(
                id: id,
                noteId: noteId,
                body: body,
                userId: userId,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int noteId,
                required String body,
                required String userId,
                required String timestamp,
              }) => NoteActionsCompanion.insert(
                id: id,
                noteId: noteId,
                body: body,
                userId: userId,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.noteId,
                                referencedTable: $$NoteActionsTableReferences
                                    ._noteIdTable(db),
                                referencedColumn: $$NoteActionsTableReferences
                                    ._noteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteActionsTable,
      NoteAction,
      $$NoteActionsTableFilterComposer,
      $$NoteActionsTableOrderingComposer,
      $$NoteActionsTableAnnotationComposer,
      $$NoteActionsTableCreateCompanionBuilder,
      $$NoteActionsTableUpdateCompanionBuilder,
      (NoteAction, $$NoteActionsTableReferences),
      NoteAction,
      PrefetchHooks Function({bool noteId})
    >;
typedef $$NoteFixturesTableCreateCompanionBuilder =
    NoteFixturesCompanion Function({
      Value<int> id,
      required int noteId,
      required int fixtureId,
    });
typedef $$NoteFixturesTableUpdateCompanionBuilder =
    NoteFixturesCompanion Function({
      Value<int> id,
      Value<int> noteId,
      Value<int> fixtureId,
    });

final class $$NoteFixturesTableReferences
    extends BaseReferences<_$AppDatabase, $NoteFixturesTable, NoteFixture> {
  $$NoteFixturesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) => db.notes.createAlias(
    $_aliasNameGenerator(db.noteFixtures.noteId, db.notes.id),
  );

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FixturesTable _fixtureIdTable(_$AppDatabase db) =>
      db.fixtures.createAlias(
        $_aliasNameGenerator(db.noteFixtures.fixtureId, db.fixtures.id),
      );

  $$FixturesTableProcessedTableManager get fixtureId {
    final $_column = $_itemColumn<int>('fixture_id')!;

    final manager = $$FixturesTableTableManager(
      $_db,
      $_db.fixtures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixtureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteFixturesTableFilterComposer
    extends Composer<_$AppDatabase, $NoteFixturesTable> {
  $$NoteFixturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturesTableFilterComposer get fixtureId {
    final $$FixturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableFilterComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteFixturesTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteFixturesTable> {
  $$NoteFixturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturesTableOrderingComposer get fixtureId {
    final $$FixturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableOrderingComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteFixturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteFixturesTable> {
  $$NoteFixturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixturesTableAnnotationComposer get fixtureId {
    final $$FixturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixtureId,
      referencedTable: $db.fixtures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixturesTableAnnotationComposer(
            $db: $db,
            $table: $db.fixtures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteFixturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteFixturesTable,
          NoteFixture,
          $$NoteFixturesTableFilterComposer,
          $$NoteFixturesTableOrderingComposer,
          $$NoteFixturesTableAnnotationComposer,
          $$NoteFixturesTableCreateCompanionBuilder,
          $$NoteFixturesTableUpdateCompanionBuilder,
          (NoteFixture, $$NoteFixturesTableReferences),
          NoteFixture,
          PrefetchHooks Function({bool noteId, bool fixtureId})
        > {
  $$NoteFixturesTableTableManager(_$AppDatabase db, $NoteFixturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteFixturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteFixturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteFixturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> noteId = const Value.absent(),
                Value<int> fixtureId = const Value.absent(),
              }) => NoteFixturesCompanion(
                id: id,
                noteId: noteId,
                fixtureId: fixtureId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int noteId,
                required int fixtureId,
              }) => NoteFixturesCompanion.insert(
                id: id,
                noteId: noteId,
                fixtureId: fixtureId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteFixturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, fixtureId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.noteId,
                                referencedTable: $$NoteFixturesTableReferences
                                    ._noteIdTable(db),
                                referencedColumn: $$NoteFixturesTableReferences
                                    ._noteIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (fixtureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fixtureId,
                                referencedTable: $$NoteFixturesTableReferences
                                    ._fixtureIdTable(db),
                                referencedColumn: $$NoteFixturesTableReferences
                                    ._fixtureIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteFixturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteFixturesTable,
      NoteFixture,
      $$NoteFixturesTableFilterComposer,
      $$NoteFixturesTableOrderingComposer,
      $$NoteFixturesTableAnnotationComposer,
      $$NoteFixturesTableCreateCompanionBuilder,
      $$NoteFixturesTableUpdateCompanionBuilder,
      (NoteFixture, $$NoteFixturesTableReferences),
      NoteFixture,
      PrefetchHooks Function({bool noteId, bool fixtureId})
    >;
typedef $$NotePositionsTableCreateCompanionBuilder =
    NotePositionsCompanion Function({
      Value<int> id,
      required int noteId,
      required String positionName,
    });
typedef $$NotePositionsTableUpdateCompanionBuilder =
    NotePositionsCompanion Function({
      Value<int> id,
      Value<int> noteId,
      Value<String> positionName,
    });

final class $$NotePositionsTableReferences
    extends BaseReferences<_$AppDatabase, $NotePositionsTable, NotePosition> {
  $$NotePositionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NotesTable _noteIdTable(_$AppDatabase db) => db.notes.createAlias(
    $_aliasNameGenerator(db.notePositions.noteId, db.notes.id),
  );

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotePositionsTableFilterComposer
    extends Composer<_$AppDatabase, $NotePositionsTable> {
  $$NotePositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionName => $composableBuilder(
    column: $table.positionName,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotePositionsTable> {
  $$NotePositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionName => $composableBuilder(
    column: $table.positionName,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotePositionsTable> {
  $$NotePositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get positionName => $composableBuilder(
    column: $table.positionName,
    builder: (column) => column,
  );

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotePositionsTable,
          NotePosition,
          $$NotePositionsTableFilterComposer,
          $$NotePositionsTableOrderingComposer,
          $$NotePositionsTableAnnotationComposer,
          $$NotePositionsTableCreateCompanionBuilder,
          $$NotePositionsTableUpdateCompanionBuilder,
          (NotePosition, $$NotePositionsTableReferences),
          NotePosition,
          PrefetchHooks Function({bool noteId})
        > {
  $$NotePositionsTableTableManager(_$AppDatabase db, $NotePositionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotePositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotePositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotePositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> noteId = const Value.absent(),
                Value<String> positionName = const Value.absent(),
              }) => NotePositionsCompanion(
                id: id,
                noteId: noteId,
                positionName: positionName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int noteId,
                required String positionName,
              }) => NotePositionsCompanion.insert(
                id: id,
                noteId: noteId,
                positionName: positionName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotePositionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.noteId,
                                referencedTable: $$NotePositionsTableReferences
                                    ._noteIdTable(db),
                                referencedColumn: $$NotePositionsTableReferences
                                    ._noteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotePositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotePositionsTable,
      NotePosition,
      $$NotePositionsTableFilterComposer,
      $$NotePositionsTableOrderingComposer,
      $$NotePositionsTableAnnotationComposer,
      $$NotePositionsTableCreateCompanionBuilder,
      $$NotePositionsTableUpdateCompanionBuilder,
      (NotePosition, $$NotePositionsTableReferences),
      NotePosition,
      PrefetchHooks Function({bool noteId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShowMetaTableTableManager get showMeta =>
      $$ShowMetaTableTableManager(_db, _db.showMeta);
  $$UsersLocalTableTableManager get usersLocal =>
      $$UsersLocalTableTableManager(_db, _db.usersLocal);
  $$LightingPositionsTableTableManager get lightingPositions =>
      $$LightingPositionsTableTableManager(_db, _db.lightingPositions);
  $$CircuitsTableTableManager get circuits =>
      $$CircuitsTableTableManager(_db, _db.circuits);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$AddressesTableTableManager get addresses =>
      $$AddressesTableTableManager(_db, _db.addresses);
  $$DimmersTableTableManager get dimmers =>
      $$DimmersTableTableManager(_db, _db.dimmers);
  $$FixtureTypesTableTableManager get fixtureTypes =>
      $$FixtureTypesTableTableManager(_db, _db.fixtureTypes);
  $$FixturesTableTableManager get fixtures =>
      $$FixturesTableTableManager(_db, _db.fixtures);
  $$FixturePartsTableTableManager get fixtureParts =>
      $$FixturePartsTableTableManager(_db, _db.fixtureParts);
  $$GelsTableTableManager get gels => $$GelsTableTableManager(_db, _db.gels);
  $$GobosTableTableManager get gobos =>
      $$GobosTableTableManager(_db, _db.gobos);
  $$AccessoriesTableTableManager get accessories =>
      $$AccessoriesTableTableManager(_db, _db.accessories);
  $$WorkNotesTableTableManager get workNotes =>
      $$WorkNotesTableTableManager(_db, _db.workNotes);
  $$MaintenanceLogTableTableManager get maintenanceLog =>
      $$MaintenanceLogTableTableManager(_db, _db.maintenanceLog);
  $$CustomFieldsTableTableManager get customFields =>
      $$CustomFieldsTableTableManager(_db, _db.customFields);
  $$CustomFieldValuesTableTableManager get customFieldValues =>
      $$CustomFieldValuesTableTableManager(_db, _db.customFieldValues);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$CommitsTableTableManager get commits =>
      $$CommitsTableTableManager(_db, _db.commits);
  $$RevisionsTableTableManager get revisions =>
      $$RevisionsTableTableManager(_db, _db.revisions);
  $$PositionGroupsTableTableManager get positionGroups =>
      $$PositionGroupsTableTableManager(_db, _db.positionGroups);
  $$RoleContactsTableTableManager get roleContacts =>
      $$RoleContactsTableTableManager(_db, _db.roleContacts);
  $$SpreadsheetViewPresetsTableTableManager get spreadsheetViewPresets =>
      $$SpreadsheetViewPresetsTableTableManager(
        _db,
        _db.spreadsheetViewPresets,
      );
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteActionsTableTableManager get noteActions =>
      $$NoteActionsTableTableManager(_db, _db.noteActions);
  $$NoteFixturesTableTableManager get noteFixtures =>
      $$NoteFixturesTableTableManager(_db, _db.noteFixtures);
  $$NotePositionsTableTableManager get notePositions =>
      $$NotePositionsTableTableManager(_db, _db.notePositions);
}
