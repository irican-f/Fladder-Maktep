// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jellybot.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiClientDto _$ApiClientDtoFromJson(Map<String, dynamic> json) => ApiClientDto(
  id: json['id'] as String?,
  name: json['name'] as String?,
  type: json['type'] as String?,
  baseUrl: json['baseUrl'] as String?,
  username: json['username'] as String?,
  hasApiKey: json['hasApiKey'] as bool?,
  hasPassword: json['hasPassword'] as bool?,
  isEnabled: json['isEnabled'] as bool?,
  isActive: json['isActive'] as bool?,
  subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
      ? null
      : DateTime.parse(json['subscriptionExpiresAt'] as String),
  priority: (json['priority'] as num?)?.toInt(),
  maxConcurrentRequests: (json['maxConcurrentRequests'] as num?)?.toInt(),
  rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt(),
  isTorrentClient: json['isTorrentClient'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ApiClientDtoToJson(
  ApiClientDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'name': ?instance.name,
  'type': ?instance.type,
  'baseUrl': ?instance.baseUrl,
  'username': ?instance.username,
  'hasApiKey': ?instance.hasApiKey,
  'hasPassword': ?instance.hasPassword,
  'isEnabled': ?instance.isEnabled,
  'isActive': ?instance.isActive,
  'subscriptionExpiresAt': ?instance.subscriptionExpiresAt?.toIso8601String(),
  'priority': ?instance.priority,
  'maxConcurrentRequests': ?instance.maxConcurrentRequests,
  'rateLimitPerMinute': ?instance.rateLimitPerMinute,
  'isTorrentClient': ?instance.isTorrentClient,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'updatedAt': ?instance.updatedAt?.toIso8601String(),
};

ProblemDetails _$ProblemDetailsFromJson(Map<String, dynamic> json) =>
    ProblemDetails(
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: (json['status'] as num?)?.toInt(),
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
      extensions: json['extensions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProblemDetailsToJson(ProblemDetails instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'title': ?instance.title,
      'status': ?instance.status,
      'detail': ?instance.detail,
      'instance': ?instance.instance,
      'extensions': ?instance.extensions,
    };

CreateApiClientRequest _$CreateApiClientRequestFromJson(
  Map<String, dynamic> json,
) => CreateApiClientRequest(
  name: json['name'] as String?,
  type: json['type'] as String?,
  baseUrl: json['baseUrl'] as String?,
  apiKey: json['apiKey'] as String?,
  username: json['username'] as String?,
  password: json['password'] as String?,
  isEnabled: json['isEnabled'] as bool?,
  subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
      ? null
      : DateTime.parse(json['subscriptionExpiresAt'] as String),
  priority: (json['priority'] as num?)?.toInt(),
  maxConcurrentRequests: (json['maxConcurrentRequests'] as num?)?.toInt(),
  rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt(),
  isTorrentClient: json['isTorrentClient'] as bool?,
);

Map<String, dynamic> _$CreateApiClientRequestToJson(
  CreateApiClientRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'type': ?instance.type,
  'baseUrl': ?instance.baseUrl,
  'apiKey': ?instance.apiKey,
  'username': ?instance.username,
  'password': ?instance.password,
  'isEnabled': ?instance.isEnabled,
  'subscriptionExpiresAt': ?instance.subscriptionExpiresAt?.toIso8601String(),
  'priority': ?instance.priority,
  'maxConcurrentRequests': ?instance.maxConcurrentRequests,
  'rateLimitPerMinute': ?instance.rateLimitPerMinute,
  'isTorrentClient': ?instance.isTorrentClient,
};

UpdateApiClientRequest _$UpdateApiClientRequestFromJson(
  Map<String, dynamic> json,
) => UpdateApiClientRequest(
  name: json['name'] as String?,
  type: json['type'] as String?,
  baseUrl: json['baseUrl'] as String?,
  apiKey: json['apiKey'] as String?,
  username: json['username'] as String?,
  password: json['password'] as String?,
  isEnabled: json['isEnabled'] as bool?,
  subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
      ? null
      : DateTime.parse(json['subscriptionExpiresAt'] as String),
  priority: (json['priority'] as num?)?.toInt(),
  maxConcurrentRequests: (json['maxConcurrentRequests'] as num?)?.toInt(),
  rateLimitPerMinute: (json['rateLimitPerMinute'] as num?)?.toInt(),
  isTorrentClient: json['isTorrentClient'] as bool?,
);

Map<String, dynamic> _$UpdateApiClientRequestToJson(
  UpdateApiClientRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'type': ?instance.type,
  'baseUrl': ?instance.baseUrl,
  'apiKey': ?instance.apiKey,
  'username': ?instance.username,
  'password': ?instance.password,
  'isEnabled': ?instance.isEnabled,
  'subscriptionExpiresAt': ?instance.subscriptionExpiresAt?.toIso8601String(),
  'priority': ?instance.priority,
  'maxConcurrentRequests': ?instance.maxConcurrentRequests,
  'rateLimitPerMinute': ?instance.rateLimitPerMinute,
  'isTorrentClient': ?instance.isTorrentClient,
};

PaginatedResponseOfCrawlLinkDto _$PaginatedResponseOfCrawlLinkDtoFromJson(
  Map<String, dynamic> json,
) => PaginatedResponseOfCrawlLinkDto(
  currentPage: (json['currentPage'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CrawlLinkDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$PaginatedResponseOfCrawlLinkDtoToJson(
  PaginatedResponseOfCrawlLinkDto instance,
) => <String, dynamic>{
  'currentPage': ?instance.currentPage,
  'totalPages': ?instance.totalPages,
  'pageSize': ?instance.pageSize,
  'totalCount': ?instance.totalCount,
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
};

CrawlLinkDto _$CrawlLinkDtoFromJson(Map<String, dynamic> json) => CrawlLinkDto(
  id: json['id'] as String?,
  mediaId: json['mediaId'] as String?,
  name: json['name'] as String?,
  secondName: json['secondName'] as String?,
  provider: json['provider'],
  providerId: json['providerId'] as String?,
  providerItemId: json['providerItemId'] as String?,
  providerCategory: json['providerCategory'] as String?,
  category: mediaCategoryNullableFromJson(json['category']),
  fullUrl: json['fullUrl'] as String?,
  relativeUrl: json['relativeUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  airedEpisodesCount: (json['airedEpisodesCount'] as num?)?.toInt(),
  totalEpisodesCount: (json['totalEpisodesCount'] as num?)?.toInt(),
  season: (json['season'] as num?)?.toInt(),
  quality: json['quality'] as String?,
  version: json['version'] as String?,
  productionYear: (json['productionYear'] as num?)?.toInt(),
  lastChecked: json['lastChecked'] == null
      ? null
      : DateTime.parse(json['lastChecked'] as String),
  downloaded: json['downloaded'] as bool?,
  hasError: json['hasError'] as bool?,
  createdBy: json['createdBy'] as String?,
  authorId: json['authorId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  origin: creationOriginNullableFromJson(json['origin']),
  mediaServerType: mediaServerTypeNullableFromJson(json['mediaServerType']),
  isEnabled: json['isEnabled'] as bool?,
  disabledHosts:
      (json['disabledHosts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$CrawlLinkDtoToJson(
  CrawlLinkDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'mediaId': ?instance.mediaId,
  'name': ?instance.name,
  'secondName': ?instance.secondName,
  'provider': ?instance.provider,
  'providerId': ?instance.providerId,
  'providerItemId': ?instance.providerItemId,
  'providerCategory': ?instance.providerCategory,
  'category': ?mediaCategoryNullableToJson(instance.category),
  'fullUrl': ?instance.fullUrl,
  'relativeUrl': ?instance.relativeUrl,
  'thumbnailUrl': ?instance.thumbnailUrl,
  'airedEpisodesCount': ?instance.airedEpisodesCount,
  'totalEpisodesCount': ?instance.totalEpisodesCount,
  'season': ?instance.season,
  'quality': ?instance.quality,
  'version': ?instance.version,
  'productionYear': ?instance.productionYear,
  'lastChecked': ?instance.lastChecked?.toIso8601String(),
  'downloaded': ?instance.downloaded,
  'hasError': ?instance.hasError,
  'createdBy': ?instance.createdBy,
  'authorId': ?instance.authorId,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'origin': ?creationOriginNullableToJson(instance.origin),
  'mediaServerType': ?mediaServerTypeNullableToJson(instance.mediaServerType),
  'isEnabled': ?instance.isEnabled,
  'disabledHosts': ?instance.disabledHosts,
};

ProviderDto _$ProviderDtoFromJson(Map<String, dynamic> json) => ProviderDto(
  displayName: json['displayName'] as String?,
  name: json['name'] as String?,
  url: json['url'] as String?,
  enabled: json['enabled'] as bool?,
  searchEnabled: json['searchEnabled'] as bool?,
  isManuallyDisabled: json['isManuallyDisabled'] as bool?,
);

Map<String, dynamic> _$ProviderDtoToJson(ProviderDto instance) =>
    <String, dynamic>{
      'displayName': ?instance.displayName,
      'name': ?instance.name,
      'url': ?instance.url,
      'enabled': ?instance.enabled,
      'searchEnabled': ?instance.searchEnabled,
      'isManuallyDisabled': ?instance.isManuallyDisabled,
    };

ExtractMediaResponse _$ExtractMediaResponseFromJson(
  Map<String, dynamic> json,
) => ExtractMediaResponse(
  requiresSeasonSelection: json['requiresSeasonSelection'] as bool?,
  availableSeasons: (json['availableSeasons'] as num?)?.toInt(),
  mediaTitle: json['mediaTitle'] as String?,
  originalUrl: json['originalUrl'] as String?,
  addToken: json['addToken'] as String?,
  crawlLink: json['crawlLink'],
  mediaExistsOnServer: json['mediaExistsOnServer'] as bool?,
  requiresExistenceConfirmation: json['requiresExistenceConfirmation'] as bool?,
  existingMedia: json['existingMedia'],
);

Map<String, dynamic> _$ExtractMediaResponseToJson(
  ExtractMediaResponse instance,
) => <String, dynamic>{
  'requiresSeasonSelection': ?instance.requiresSeasonSelection,
  'availableSeasons': ?instance.availableSeasons,
  'mediaTitle': ?instance.mediaTitle,
  'originalUrl': ?instance.originalUrl,
  'addToken': ?instance.addToken,
  'crawlLink': ?instance.crawlLink,
  'mediaExistsOnServer': ?instance.mediaExistsOnServer,
  'requiresExistenceConfirmation': ?instance.requiresExistenceConfirmation,
  'existingMedia': ?instance.existingMedia,
};

MediaSearchResultDto _$MediaSearchResultDtoFromJson(
  Map<String, dynamic> json,
) => MediaSearchResultDto(
  id: json['id'] as String?,
  title: json['title'] as String?,
  originalTitle: json['originalTitle'] as String?,
  productionYear: (json['productionYear'] as num?)?.toInt(),
  isShow: json['isShow'] as bool?,
  mediaUrl: json['mediaUrl'] as String?,
);

Map<String, dynamic> _$MediaSearchResultDtoToJson(
  MediaSearchResultDto instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'title': ?instance.title,
  'originalTitle': ?instance.originalTitle,
  'productionYear': ?instance.productionYear,
  'isShow': ?instance.isShow,
  'mediaUrl': ?instance.mediaUrl,
};

ExtractMediaRequest _$ExtractMediaRequestFromJson(Map<String, dynamic> json) =>
    ExtractMediaRequest(
      url: json['url'] as String?,
      userName: json['userName'] as String?,
      userId: json['userId'] as String?,
      mediaCategory: mediaCategoryNullableFromJson(json['mediaCategory']),
    );

Map<String, dynamic> _$ExtractMediaRequestToJson(
  ExtractMediaRequest instance,
) => <String, dynamic>{
  'url': ?instance.url,
  'userName': ?instance.userName,
  'userId': ?instance.userId,
  'mediaCategory': ?mediaCategoryNullableToJson(instance.mediaCategory),
};

SelectSeasonRequest _$SelectSeasonRequestFromJson(Map<String, dynamic> json) =>
    SelectSeasonRequest(
      url: json['url'] as String?,
      season: (json['season'] as num?)?.toInt(),
      userName: json['userName'] as String?,
      userId: json['userId'] as String?,
      mediaCategory: mediaCategoryNullableFromJson(json['mediaCategory']),
    );

Map<String, dynamic> _$SelectSeasonRequestToJson(
  SelectSeasonRequest instance,
) => <String, dynamic>{
  'url': ?instance.url,
  'season': ?instance.season,
  'userName': ?instance.userName,
  'userId': ?instance.userId,
  'mediaCategory': ?mediaCategoryNullableToJson(instance.mediaCategory),
};

ExtractMediaConfirmationRequest _$ExtractMediaConfirmationRequestFromJson(
  Map<String, dynamic> json,
) => ExtractMediaConfirmationRequest(
  addToken: json['addToken'] as String?,
  mediaTitle: json['mediaTitle'] as String?,
);

Map<String, dynamic> _$ExtractMediaConfirmationRequestToJson(
  ExtractMediaConfirmationRequest instance,
) => <String, dynamic>{
  'addToken': ?instance.addToken,
  'mediaTitle': ?instance.mediaTitle,
};

RenameLinkResult _$RenameLinkResultFromJson(Map<String, dynamic> json) =>
    RenameLinkResult(
      isSuccess: json['isSuccess'] as bool?,
      error: json['error'] as String?,
      oldName: json['oldName'] as String?,
      newName: json['newName'] as String?,
    );

Map<String, dynamic> _$RenameLinkResultToJson(RenameLinkResult instance) =>
    <String, dynamic>{
      'isSuccess': ?instance.isSuccess,
      'error': ?instance.error,
      'oldName': ?instance.oldName,
      'newName': ?instance.newName,
    };

RenameCrawlLinkRequest _$RenameCrawlLinkRequestFromJson(
  Map<String, dynamic> json,
) => RenameCrawlLinkRequest(newName: json['newName'] as String?);

Map<String, dynamic> _$RenameCrawlLinkRequestToJson(
  RenameCrawlLinkRequest instance,
) => <String, dynamic>{'newName': ?instance.newName};

UpdateCrawlLinkRequest _$UpdateCrawlLinkRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCrawlLinkRequest(
  name: json['name'] as String?,
  secondName: json['secondName'] as String?,
  url: json['url'] as String?,
  providerCategory: json['providerCategory'] as String?,
  category: json['category'],
  thumbnailUrl: json['thumbnailUrl'] as String?,
  airedEpisodesCount: (json['airedEpisodesCount'] as num?)?.toInt(),
  totalEpisodesCount: (json['totalEpisodesCount'] as num?)?.toInt(),
  season: (json['season'] as num?)?.toInt(),
  quality: json['quality'] as String?,
  version: json['version'] as String?,
  productionYear: (json['productionYear'] as num?)?.toInt(),
  lastChecked: json['lastChecked'] == null
      ? null
      : DateTime.parse(json['lastChecked'] as String),
  clearLastChecked: json['clearLastChecked'] as bool?,
  downloaded: json['downloaded'] as bool?,
  hasError: json['hasError'] as bool?,
  isEnabled: json['isEnabled'] as bool?,
  disabledHosts:
      (json['disabledHosts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$UpdateCrawlLinkRequestToJson(
  UpdateCrawlLinkRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'secondName': ?instance.secondName,
  'url': ?instance.url,
  'providerCategory': ?instance.providerCategory,
  'category': ?instance.category,
  'thumbnailUrl': ?instance.thumbnailUrl,
  'airedEpisodesCount': ?instance.airedEpisodesCount,
  'totalEpisodesCount': ?instance.totalEpisodesCount,
  'season': ?instance.season,
  'quality': ?instance.quality,
  'version': ?instance.version,
  'productionYear': ?instance.productionYear,
  'lastChecked': ?instance.lastChecked?.toIso8601String(),
  'clearLastChecked': ?instance.clearLastChecked,
  'downloaded': ?instance.downloaded,
  'hasError': ?instance.hasError,
  'isEnabled': ?instance.isEnabled,
  'disabledHosts': ?instance.disabledHosts,
};

UpdateDisabledHostsRequest _$UpdateDisabledHostsRequestFromJson(
  Map<String, dynamic> json,
) => UpdateDisabledHostsRequest(
  hosts:
      (json['hosts'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$UpdateDisabledHostsRequestToJson(
  UpdateDisabledHostsRequest instance,
) => <String, dynamic>{'hosts': ?instance.hosts};

DownloadDto _$DownloadDtoFromJson(Map<String, dynamic> json) => DownloadDto(
  name: json['name'] as String?,
  fileName: json['fileName'] as String?,
  url: json['url'] as String?,
  destinationFolder: json['destinationFolder'] as String?,
  isRunning: json['isRunning'] as bool?,
  isCancelled: json['isCancelled'] as bool?,
  isCompleted: json['isCompleted'] as bool?,
  isDeadLink: json['isDeadLink'] as bool?,
  episodeIndex: (json['episodeIndex'] as num?)?.toInt(),
  progress: (json['progress'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  speedUnit: json['speedUnit'] as String?,
  averageSpeed: (json['averageSpeed'] as num?)?.toDouble(),
  averageSpeedUnit: json['averageSpeedUnit'] as String?,
  sizeReceived: (json['sizeReceived'] as num?)?.toDouble(),
  sizeUnit: json['sizeUnit'] as String?,
  totalSize: (json['totalSize'] as num?)?.toDouble(),
  totalSizeUnit: json['totalSizeUnit'] as String?,
  estimatedTime: (json['estimatedTime'] as num?)?.toInt(),
  estimatedTimeUnit: json['estimatedTimeUnit'] as String?,
);

Map<String, dynamic> _$DownloadDtoToJson(DownloadDto instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'fileName': ?instance.fileName,
      'url': ?instance.url,
      'destinationFolder': ?instance.destinationFolder,
      'isRunning': ?instance.isRunning,
      'isCancelled': ?instance.isCancelled,
      'isCompleted': ?instance.isCompleted,
      'isDeadLink': ?instance.isDeadLink,
      'episodeIndex': ?instance.episodeIndex,
      'progress': ?instance.progress,
      'speed': ?instance.speed,
      'speedUnit': ?instance.speedUnit,
      'averageSpeed': ?instance.averageSpeed,
      'averageSpeedUnit': ?instance.averageSpeedUnit,
      'sizeReceived': ?instance.sizeReceived,
      'sizeUnit': ?instance.sizeUnit,
      'totalSize': ?instance.totalSize,
      'totalSizeUnit': ?instance.totalSizeUnit,
      'estimatedTime': ?instance.estimatedTime,
      'estimatedTimeUnit': ?instance.estimatedTimeUnit,
    };

MediaServerInviteRequest _$MediaServerInviteRequestFromJson(
  Map<String, dynamic> json,
) => MediaServerInviteRequest(
  email: json['email'] as String?,
  libraries:
      (json['libraries'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$MediaServerInviteRequestToJson(
  MediaServerInviteRequest instance,
) => <String, dynamic>{
  'email': ?instance.email,
  'libraries': ?instance.libraries,
};

ScheduledJob _$ScheduledJobFromJson(Map<String, dynamic> json) => ScheduledJob(
  id: json['id'] as String?,
  type: json['type'] as String?,
  status: json['status'] as String?,
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
);

Map<String, dynamic> _$ScheduledJobToJson(ScheduledJob instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'type': ?instance.type,
      'status': ?instance.status,
      'startedAt': ?instance.startedAt?.toIso8601String(),
    };

TriggerJobRequest _$TriggerJobRequestFromJson(Map<String, dynamic> json) =>
    TriggerJobRequest(jobType: json['jobType'] as String?);

Map<String, dynamic> _$TriggerJobRequestToJson(TriggerJobRequest instance) =>
    <String, dynamic>{'jobType': ?instance.jobType};

LiveTvChannelDto _$LiveTvChannelDtoFromJson(Map<String, dynamic> json) =>
    LiveTvChannelDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      iconUrl: json['iconUrl'] as String?,
      category: liveTvChannelCategoryNullableFromJson(json['category']),
      streamUrl: json['streamUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LiveTvChannelDtoToJson(LiveTvChannelDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'iconUrl': ?instance.iconUrl,
      'category': ?liveTvChannelCategoryNullableToJson(instance.category),
      'streamUrl': ?instance.streamUrl,
      'createdAt': ?instance.createdAt?.toIso8601String(),
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
    };

DebridLinkResult _$DebridLinkResultFromJson(Map<String, dynamic> json) =>
    DebridLinkResult(
      isSuccess: json['isSuccess'] as bool?,
      error: json['error'] as String?,
      debridedUrl: json['debridedUrl'] as String?,
    );

Map<String, dynamic> _$DebridLinkResultToJson(DebridLinkResult instance) =>
    <String, dynamic>{
      'isSuccess': ?instance.isSuccess,
      'error': ?instance.error,
      'debridedUrl': ?instance.debridedUrl,
    };

DebridLinkRequest _$DebridLinkRequestFromJson(Map<String, dynamic> json) =>
    DebridLinkRequest(link: json['link'] as String?);

Map<String, dynamic> _$DebridLinkRequestToJson(DebridLinkRequest instance) =>
    <String, dynamic>{'link': ?instance.link};

RemoveLinkResult _$RemoveLinkResultFromJson(Map<String, dynamic> json) =>
    RemoveLinkResult(
      isSuccess: json['isSuccess'] as bool?,
      error: json['error'] as String?,
      removedLink: json['removedLink'] as String?,
    );

Map<String, dynamic> _$RemoveLinkResultToJson(RemoveLinkResult instance) =>
    <String, dynamic>{
      'isSuccess': ?instance.isSuccess,
      'error': ?instance.error,
      'removedLink': ?instance.removedLink,
    };

RemoveCorruptedFileResult _$RemoveCorruptedFileResultFromJson(
  Map<String, dynamic> json,
) => RemoveCorruptedFileResult(
  isSuccess: json['isSuccess'] as bool?,
  error: json['error'] as String?,
  episodesRemoved: (json['episodesRemoved'] as num?)?.toInt(),
);

Map<String, dynamic> _$RemoveCorruptedFileResultToJson(
  RemoveCorruptedFileResult instance,
) => <String, dynamic>{
  'isSuccess': ?instance.isSuccess,
  'error': ?instance.error,
  'episodesRemoved': ?instance.episodesRemoved,
};

RemoveCorruptedFileRequest _$RemoveCorruptedFileRequestFromJson(
  Map<String, dynamic> json,
) => RemoveCorruptedFileRequest(
  crawlLinkId: json['crawlLinkId'] as String?,
  episodeIndexes:
      (json['episodeIndexes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
);

Map<String, dynamic> _$RemoveCorruptedFileRequestToJson(
  RemoveCorruptedFileRequest instance,
) => <String, dynamic>{
  'crawlLinkId': ?instance.crawlLinkId,
  'episodeIndexes': ?instance.episodeIndexes,
};

IProvider _$IProviderFromJson(Map<String, dynamic> json) => IProvider(
  id: json['id'] as String?,
  displayName: json['displayName'] as String?,
  name: json['name'] as String?,
  url: json['url'] as String?,
  enabled: json['enabled'] as bool?,
  searchEnabled: json['searchEnabled'] as bool?,
  isManuallyDisabled: json['isManuallyDisabled'] as bool?,
  crawlLinksRef:
      (json['crawlLinksRef'] as List<dynamic>?)
          ?.map((e) => ICrawlLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$IProviderToJson(IProvider instance) => <String, dynamic>{
  'id': ?instance.id,
  'displayName': ?instance.displayName,
  'name': ?instance.name,
  'url': ?instance.url,
  'enabled': ?instance.enabled,
  'searchEnabled': ?instance.searchEnabled,
  'isManuallyDisabled': ?instance.isManuallyDisabled,
  'crawlLinksRef': ?instance.crawlLinksRef?.map((e) => e.toJson()).toList(),
};

ICrawlLink _$ICrawlLinkFromJson(Map<String, dynamic> json) => ICrawlLink(
  id: json['id'] as String?,
  mediaId: json['mediaId'] as String?,
  name: json['name'] as String?,
  secondName: json['secondName'] as String?,
  formattedName: json['formattedName'] as String?,
  providerId: json['providerId'] as String?,
  providerRef: json['providerRef'] == null
      ? null
      : IProvider.fromJson(json['providerRef'] as Map<String, dynamic>),
  providerItemId: json['providerItemId'] as String?,
  providerCategory: json['providerCategory'] as String?,
  category: mediaCategoryNullableFromJson(json['category']),
  url: json['url'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  airedEpisodesCount: (json['airedEpisodesCount'] as num?)?.toInt(),
  totalEpisodesCount: (json['totalEpisodesCount'] as num?)?.toInt(),
  season: (json['season'] as num?)?.toInt(),
  quality: json['quality'] as String?,
  version: json['version'] as String?,
  productionYear: (json['productionYear'] as num?)?.toInt(),
  lastChecked: json['lastChecked'] == null
      ? null
      : DateTime.parse(json['lastChecked'] as String),
  downloaded: json['downloaded'] as bool?,
  hasError: json['hasError'] as bool?,
  createdBy: json['createdBy'] as String?,
  authorId: json['authorId'] as String?,
  isEnabled: json['isEnabled'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  origin: creationOriginNullableFromJson(json['origin']),
  mediaServerType: mediaServerTypeNullableFromJson(json['mediaServerType']),
  runningCrawl: json['runningCrawl'],
);

Map<String, dynamic> _$ICrawlLinkToJson(
  ICrawlLink instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'mediaId': ?instance.mediaId,
  'name': ?instance.name,
  'secondName': ?instance.secondName,
  'formattedName': ?instance.formattedName,
  'providerId': ?instance.providerId,
  'providerRef': ?instance.providerRef?.toJson(),
  'providerItemId': ?instance.providerItemId,
  'providerCategory': ?instance.providerCategory,
  'category': ?mediaCategoryNullableToJson(instance.category),
  'url': ?instance.url,
  'thumbnailUrl': ?instance.thumbnailUrl,
  'airedEpisodesCount': ?instance.airedEpisodesCount,
  'totalEpisodesCount': ?instance.totalEpisodesCount,
  'season': ?instance.season,
  'quality': ?instance.quality,
  'version': ?instance.version,
  'productionYear': ?instance.productionYear,
  'lastChecked': ?instance.lastChecked?.toIso8601String(),
  'downloaded': ?instance.downloaded,
  'hasError': ?instance.hasError,
  'createdBy': ?instance.createdBy,
  'authorId': ?instance.authorId,
  'isEnabled': ?instance.isEnabled,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'origin': ?creationOriginNullableToJson(instance.origin),
  'mediaServerType': ?mediaServerTypeNullableToJson(instance.mediaServerType),
  'runningCrawl': ?instance.runningCrawl,
};

IScheduledCrawl _$IScheduledCrawlFromJson(Map<String, dynamic> json) =>
    IScheduledCrawl(
      id: json['id'] as String?,
      crawlLinkId: json['crawlLinkId'] as String?,
      jobId: json['jobId'] as String?,
      crawlLinkRef: json['crawlLinkRef'] == null
          ? null
          : ICrawlLink.fromJson(json['crawlLinkRef'] as Map<String, dynamic>),
      name: json['name'] as String?,
      mediaName: json['mediaName'] as String?,
      mediaFolder: json['mediaFolder'] as String?,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      downloadLinks:
          (json['downloadLinks'] as List<dynamic>?)
              ?.map((e) => DownloadLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      extractedLinks:
          (json['extractedLinks'] as List<dynamic>?)
              ?.map((e) => DownloadLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      failedEpisodes:
          (json['failedEpisodes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      successfulDownloads: (json['successfulDownloads'] as num?)?.toInt(),
      skippedDownloads: (json['skippedDownloads'] as num?)?.toInt(),
      status: crawlStatusNullableFromJson(json['status']),
      hasError: json['hasError'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      extractedItemInfo: json['extractedItemInfo'],
    );

Map<String, dynamic> _$IScheduledCrawlToJson(
  IScheduledCrawl instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'crawlLinkId': ?instance.crawlLinkId,
  'jobId': ?instance.jobId,
  'crawlLinkRef': ?instance.crawlLinkRef?.toJson(),
  'name': ?instance.name,
  'mediaName': ?instance.mediaName,
  'mediaFolder': ?instance.mediaFolder,
  'url': ?instance.url,
  'thumbnailUrl': ?instance.thumbnailUrl,
  'downloadLinks': ?instance.downloadLinks?.map((e) => e.toJson()).toList(),
  'extractedLinks': ?instance.extractedLinks?.map((e) => e.toJson()).toList(),
  'failedEpisodes': ?instance.failedEpisodes,
  'successfulDownloads': ?instance.successfulDownloads,
  'skippedDownloads': ?instance.skippedDownloads,
  'status': ?crawlStatusNullableToJson(instance.status),
  'hasError': ?instance.hasError,
  'createdAt': ?instance.createdAt?.toIso8601String(),
  'extractedItemInfo': ?instance.extractedItemInfo,
};

DownloadLink _$DownloadLinkFromJson(Map<String, dynamic> json) => DownloadLink(
  index: (json['index'] as num?)?.toInt(),
  link: json['link'] as String?,
  version: json['version'] as String?,
  qualityLabel: json['quality_label'] as String?,
  quality: mediaQualityNullableFromJson(json['quality']),
  size: (json['size'] as num?)?.toDouble(),
  sizeUnit: json['size_unit'] as String?,
  fileHost: json['file_host'] as String?,
  isFullSeason: json['is_full_season'] as bool?,
);

Map<String, dynamic> _$DownloadLinkToJson(DownloadLink instance) =>
    <String, dynamic>{
      'index': ?instance.index,
      'link': ?instance.link,
      'version': ?instance.version,
      'quality_label': ?instance.qualityLabel,
      'quality': ?mediaQualityNullableToJson(instance.quality),
      'size': ?instance.size,
      'size_unit': ?instance.sizeUnit,
      'file_host': ?instance.fileHost,
      'is_full_season': ?instance.isFullSeason,
    };

IExtractedItemInfo _$IExtractedItemInfoFromJson(Map<String, dynamic> json) =>
    IExtractedItemInfo(
      provider: json['provider'] == null
          ? null
          : IProvider.fromJson(json['provider'] as Map<String, dynamic>),
      title: json['title'] as String?,
      originalTitle: json['originalTitle'] as String?,
      relativeUrl: json['relativeUrl'] as String?,
      version: json['version'] as String?,
      providerId: json['providerId'] as String?,
      season: (json['season'] as num?)?.toInt(),
      airedEpisodesCount: (json['airedEpisodesCount'] as num?)?.toInt(),
      totalEpisodesCount: (json['totalEpisodesCount'] as num?)?.toInt(),
      seasonCount: (json['seasonCount'] as num?)?.toInt(),
      quality: json['quality'] as String?,
      providerCategory: json['providerCategory'] as String?,
      productionYear: (json['productionYear'] as num?)?.toInt(),
      category: mediaCategoryNullableFromJson(json['category']),
      downloadLinks:
          (json['downloadLinks'] as List<dynamic>?)
              ?.map((e) => DownloadLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$IExtractedItemInfoToJson(IExtractedItemInfo instance) =>
    <String, dynamic>{
      'provider': ?instance.provider?.toJson(),
      'title': ?instance.title,
      'originalTitle': ?instance.originalTitle,
      'relativeUrl': ?instance.relativeUrl,
      'version': ?instance.version,
      'providerId': ?instance.providerId,
      'season': ?instance.season,
      'airedEpisodesCount': ?instance.airedEpisodesCount,
      'totalEpisodesCount': ?instance.totalEpisodesCount,
      'seasonCount': ?instance.seasonCount,
      'quality': ?instance.quality,
      'providerCategory': ?instance.providerCategory,
      'productionYear': ?instance.productionYear,
      'category': ?mediaCategoryNullableToJson(instance.category),
      'downloadLinks': ?instance.downloadLinks?.map((e) => e.toJson()).toList(),
      'thumbnailUrl': ?instance.thumbnailUrl,
    };

UpdateProviderRequest _$UpdateProviderRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProviderRequest(
  displayName: json['displayName'] as String?,
  url: json['url'] as String?,
  enabled: json['enabled'] as bool?,
  searchEnabled: json['searchEnabled'] as bool?,
  isManuallyDisabled: json['isManuallyDisabled'] as bool?,
);

Map<String, dynamic> _$UpdateProviderRequestToJson(
  UpdateProviderRequest instance,
) => <String, dynamic>{
  'displayName': ?instance.displayName,
  'url': ?instance.url,
  'enabled': ?instance.enabled,
  'searchEnabled': ?instance.searchEnabled,
  'isManuallyDisabled': ?instance.isManuallyDisabled,
};

ISearchFilter _$ISearchFilterFromJson(Map<String, dynamic> json) =>
    ISearchFilter(
      label: json['label'] as String?,
      name: json['name'] as String?,
      $value: json['value'] as String?,
      valueLabel: json['valueLabel'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) => ISearchFilterOption.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$ISearchFilterToJson(ISearchFilter instance) =>
    <String, dynamic>{
      'label': ?instance.label,
      'name': ?instance.name,
      'value': ?instance.$value,
      'valueLabel': ?instance.valueLabel,
      'options': ?instance.options?.map((e) => e.toJson()).toList(),
    };

ISearchFilterOption _$ISearchFilterOptionFromJson(Map<String, dynamic> json) =>
    ISearchFilterOption(
      label: json['label'] as String?,
      $value: json['value'] as String?,
    );

Map<String, dynamic> _$ISearchFilterOptionToJson(
  ISearchFilterOption instance,
) => <String, dynamic>{'label': ?instance.label, 'value': ?instance.$value};

PaginatedResponseOfProviderSearchItemDto
_$PaginatedResponseOfProviderSearchItemDtoFromJson(Map<String, dynamic> json) =>
    PaginatedResponseOfProviderSearchItemDto(
      currentPage: (json['currentPage'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ProviderSearchItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$PaginatedResponseOfProviderSearchItemDtoToJson(
  PaginatedResponseOfProviderSearchItemDto instance,
) => <String, dynamic>{
  'currentPage': ?instance.currentPage,
  'totalPages': ?instance.totalPages,
  'pageSize': ?instance.pageSize,
  'totalCount': ?instance.totalCount,
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
};

ProviderSearchItemDto _$ProviderSearchItemDtoFromJson(
  Map<String, dynamic> json,
) => ProviderSearchItemDto(
  title: json['title'] as String?,
  description: json['description'] as String?,
  url: json['url'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  season: (json['season'] as num?)?.toInt(),
  quality: json['quality'] as String?,
  language: json['language'] as String?,
  year: (json['year'] as num?)?.toInt(),
  score: (json['score'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProviderSearchItemDtoToJson(
  ProviderSearchItemDto instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'description': ?instance.description,
  'url': ?instance.url,
  'thumbnailUrl': ?instance.thumbnailUrl,
  'season': ?instance.season,
  'quality': ?instance.quality,
  'language': ?instance.language,
  'year': ?instance.year,
  'score': ?instance.score,
};

ApiMediaSearchRequest _$ApiMediaSearchRequestFromJson(
  Map<String, dynamic> json,
) => ApiMediaSearchRequest(
  filters:
      (json['filters'] as List<dynamic>?)
          ?.map((e) => SearchFilter.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  page: (json['page'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  query: json['query'] as String?,
  category: mediaCategoryNullableFromJson(json['category']),
  exactMatch: json['exactMatch'] as bool?,
  minScore: (json['minScore'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ApiMediaSearchRequestToJson(
  ApiMediaSearchRequest instance,
) => <String, dynamic>{
  'filters': ?instance.filters?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'pageSize': ?instance.pageSize,
  'query': ?instance.query,
  'category': ?mediaCategoryNullableToJson(instance.category),
  'exactMatch': ?instance.exactMatch,
  'minScore': ?instance.minScore,
};

SearchFilter _$SearchFilterFromJson(Map<String, dynamic> json) => SearchFilter(
  label: json['label'] as String?,
  name: json['name'] as String?,
  $value: json['value'] as String?,
  valueLabel: json['valueLabel'] as String?,
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => ISearchFilterOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$SearchFilterToJson(SearchFilter instance) =>
    <String, dynamic>{
      'label': ?instance.label,
      'name': ?instance.name,
      'value': ?instance.$value,
      'valueLabel': ?instance.valueLabel,
      'options': ?instance.options?.map((e) => e.toJson()).toList(),
    };

MediaSearchRequest _$MediaSearchRequestFromJson(Map<String, dynamic> json) =>
    MediaSearchRequest(
      query: json['query'] as String?,
      category: mediaCategoryNullableFromJson(json['category']),
      exactMatch: json['exactMatch'] as bool?,
      minScore: (json['minScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MediaSearchRequestToJson(MediaSearchRequest instance) =>
    <String, dynamic>{
      'query': ?instance.query,
      'category': ?mediaCategoryNullableToJson(instance.category),
      'exactMatch': ?instance.exactMatch,
      'minScore': ?instance.minScore,
    };

LiveTvSourceResult _$LiveTvSourceResultFromJson(Map<String, dynamic> json) =>
    LiveTvSourceResult(
      baseUrl: json['baseUrl'] as String?,
      countries:
          (json['countries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fromDatabase: json['fromDatabase'] as bool?,
    );

Map<String, dynamic> _$LiveTvSourceResultToJson(LiveTvSourceResult instance) =>
    <String, dynamic>{
      'baseUrl': ?instance.baseUrl,
      'countries': ?instance.countries,
      'fromDatabase': ?instance.fromDatabase,
    };

UpdateLiveTvSourceRequest _$UpdateLiveTvSourceRequestFromJson(
  Map<String, dynamic> json,
) => UpdateLiveTvSourceRequest(
  baseUrl: json['baseUrl'] as String?,
  countries:
      (json['countries'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$UpdateLiveTvSourceRequestToJson(
  UpdateLiveTvSourceRequest instance,
) => <String, dynamic>{
  'baseUrl': ?instance.baseUrl,
  'countries': ?instance.countries,
};

ApiTorrentsUploadPost$RequestBody _$ApiTorrentsUploadPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiTorrentsUploadPost$RequestBody(
  file: json['file'] as String?,
  mediaName: json['mediaName'] as String?,
  mediaCategory: mediaCategoryNullableFromJson(json['mediaCategory']),
  authorId: json['authorId'] as String?,
);

Map<String, dynamic> _$ApiTorrentsUploadPost$RequestBodyToJson(
  ApiTorrentsUploadPost$RequestBody instance,
) => <String, dynamic>{
  'file': ?instance.file,
  'mediaName': ?instance.mediaName,
  'mediaCategory': ?mediaCategoryNullableToJson(instance.mediaCategory),
  'authorId': ?instance.authorId,
};
