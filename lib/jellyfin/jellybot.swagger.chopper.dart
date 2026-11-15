// dart format width=80
//Generated jellyfin api code

part of 'jellybot.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Jellybot extends Jellybot {
  _$Jellybot([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Jellybot;

  @override
  Future<Response<dynamic>> _apiHealthGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'Health_Get',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Health"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/health');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<String>> _apiLogsGet({
    DateTime? date,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'Logs_GetLogs',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Logs"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/logs');
    final Map<String, dynamic> $params = <String, dynamic>{'date': date};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<List<ApiClientDto>>> _apiApiClientsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Lists every configured api client. Secrets are never returned.',
      operationId: 'ApiClient_GetApiClients',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ApiClient"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/api-clients');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<ApiClientDto>, ApiClientDto>($request);
  }

  @override
  Future<Response<ApiClientDto>> _apiApiClientsPost({
    required CreateApiClientRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Creates a new api client.',
      operationId: 'ApiClient_CreateApiClient',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ApiClient"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/api-clients');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ApiClientDto, ApiClientDto>($request);
  }

  @override
  Future<Response<ApiClientDto>> _apiApiClientsApiClientIdPut({
    required String? apiClientId,
    required UpdateApiClientRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Updates an api client. Secrets are overwritten only when a new value is sent.',
      operationId: 'ApiClient_UpdateApiClient',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ApiClient"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/api-clients/${apiClientId}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ApiClientDto, ApiClientDto>($request);
  }

  @override
  Future<Response<dynamic>> _apiApiClientsApiClientIdDelete({
    required String? apiClientId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Deletes an api client.',
      operationId: 'ApiClient_DeleteApiClient',
      consumes: [],
      produces: [],
      security: [],
      tags: ["ApiClient"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/api-clients/${apiClientId}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedResponseOfCrawlLinkDto>> _apiCrawlLinksGet({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? provider,
    Object? category,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Gets added crawl links, the results are paginated.',
      operationId: 'CrawlLink_GetAddedCrawlLinks',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'search': search,
      'status': status,
      'provider': provider,
      'category': category,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client
        .send<PaginatedResponseOfCrawlLinkDto, PaginatedResponseOfCrawlLinkDto>(
          $request,
        );
  }

  @override
  Future<Response<ExtractMediaResponse>> _apiCrawlLinksPost({
    required ExtractMediaRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          '''Extracts media information from a URL without persisting anything. If the URL points to a show
page with multiple seasons, the response indicates that season selection is required — call the
select-season endpoint with the chosen season. Otherwise the response carries an addToken; pass
it to confirm-add to commit the link.''',
      operationId: 'CrawlLink_AddCrawlLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ExtractMediaResponse, ExtractMediaResponse>($request);
  }

  @override
  Future<Response<dynamic>> _apiCrawlLinksDelete({
    String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Deletes a crawl link.',
      operationId: 'CrawlLink_DeleteCrawlLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links');
    final Map<String, dynamic> $params = <String, dynamic>{'id': id};
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<ExtractMediaResponse>> _apiCrawlLinksSelectSeasonPost({
    required SelectSeasonRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          '''Selects a season for a show page URL and previews the crawl link (without persisting). Call this
when the initial extraction returned requiresSeasonSelection = true.''',
      operationId: 'CrawlLink_SelectSeason',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links/select-season');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ExtractMediaResponse, ExtractMediaResponse>($request);
  }

  @override
  Future<Response<CrawlLinkDto>> _apiCrawlLinksConfirmAddPost({
    required ExtractMediaConfirmationRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          '''Commits a previously-previewed crawl link to the database. Call after add or select-season,
passing the addToken from that response.''',
      operationId: 'CrawlLink_ConfirmCrawlLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links/confirm-add');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CrawlLinkDto, CrawlLinkDto>($request);
  }

  @override
  Future<Response<RenameLinkResult>> _apiCrawlLinksCrawlLinkIdRenamePut({
    required String? crawlLinkId,
    required RenameCrawlLinkRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Changes the name of the show for an added link.',
      operationId: 'CrawlLink_RenameCrawlLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links/${crawlLinkId}/rename');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<RenameLinkResult, RenameLinkResult>($request);
  }

  @override
  Future<Response<CrawlLinkDto>> _apiCrawlLinksCrawlLinkIdPut({
    required String? crawlLinkId,
    required UpdateCrawlLinkRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Updates editable crawl-link fields.',
      operationId: 'CrawlLink_UpdateCrawlLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links/${crawlLinkId}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CrawlLinkDto, CrawlLinkDto>($request);
  }

  @override
  Future<Response<List<String>>> _apiCrawlLinksCrawlLinkIdDisabledHostsGet({
    required String? crawlLinkId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'CrawlLink_GetDisabledHosts',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/crawl-links/${crawlLinkId}/disabled-hosts',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<List<String>>> _apiCrawlLinksCrawlLinkIdDisabledHostsPut({
    required String? crawlLinkId,
    required UpdateDisabledHostsRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'CrawlLink_ReplaceDisabledHosts',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/crawl-links/${crawlLinkId}/disabled-hosts',
    );
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<List<String>>> _apiCrawlLinksGlobalDisabledHostsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'CrawlLink_GetGlobalDisabledHosts',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links/global-disabled-hosts');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<List<String>>> _apiCrawlLinksGlobalDisabledHostsPut({
    required UpdateDisabledHostsRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'CrawlLink_ReplaceGlobalDisabledHosts',
      consumes: [],
      produces: [],
      security: [],
      tags: ["CrawlLink"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/crawl-links/global-disabled-hosts');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<String>> _apiDebridFileHostGet({
    required String? fileHost,
    String? url,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Downloads the debrided file from a specified file host and URL.',
      operationId: 'Debrid_DownloadDebridedFile',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Debrid"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/debrid/${fileHost}');
    final Map<String, dynamic> $params = <String, dynamic>{'url': url};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<List<DownloadDto>>> _apiDownloadsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Gets all running or queued downloads',
      operationId: 'Downloads_GetDownloads',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Downloads"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/downloads');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<DownloadDto>, DownloadDto>($request);
  }

  @override
  Future<Response<dynamic>> _apiDownloadsDelete({
    String? url,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Cancels a download by its file url',
      operationId: 'Downloads_CancelDownload',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Downloads"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/downloads');
    final Map<String, dynamic> $params = <String, dynamic>{'url': url};
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiInvitesPendingGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'Invite_GetPendingInvites',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Invite"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/invites/pending');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiInvitesPost({
    required MediaServerInviteRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'Invite_InviteFriend',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Invite"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/invites');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<ScheduledJob>>> _apiJobsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'Job_GetRunningJobs',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Job"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/jobs');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<ScheduledJob>, ScheduledJob>($request);
  }

  @override
  Future<Response<dynamic>> _apiJobsPost({
    required TriggerJobRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Trigger a cron job',
      operationId: 'Job_TriggerJob',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Job"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/jobs');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiJobsDelete({
    required ScheduledJob? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Cancels a running cron job',
      operationId: 'Job_InterruptJob',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Job"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/jobs');
    final $body = body;
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<LiveTvChannelDto>>> _apiLiveTvChannelsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Gets the list of Live TV channels.',
      operationId: 'LiveTv_GetLiveTvChannels',
      consumes: [],
      produces: [],
      security: [],
      tags: ["LiveTv"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/live-tv/channels');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<LiveTvChannelDto>, LiveTvChannelDto>($request);
  }

  @override
  Future<Response<DebridLinkResult>> _apiMediaDebridLinkPost({
    required DebridLinkRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'MediaOperations_DebridLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["MediaOperations"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/media/debrid-link');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<DebridLinkResult, DebridLinkResult>($request);
  }

  @override
  Future<Response<RemoveLinkResult>> _apiMediaRemoveLinkDelete({
    String? url,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'MediaOperations_RemoveLink',
      consumes: [],
      produces: [],
      security: [],
      tags: ["MediaOperations"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/media/remove-link');
    final Map<String, dynamic> $params = <String, dynamic>{'url': url};
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<RemoveLinkResult, RemoveLinkResult>($request);
  }

  @override
  Future<Response<RemoveCorruptedFileResult>> _apiMediaCorruptedFilePost({
    required RemoveCorruptedFileRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'MediaOperations_RemoveCorruptedFile',
      consumes: [],
      produces: [],
      security: [],
      tags: ["MediaOperations"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/media/corrupted-file');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<RemoveCorruptedFileResult, RemoveCorruptedFileResult>(
      $request,
    );
  }

  @override
  Future<Response<String>> _apiMegaDebridCallbackPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'MegaDebrid_SuccessCallback',
      consumes: [],
      produces: [],
      security: [],
      tags: ["MegaDebrid"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/mega-debrid/callback');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<List<IProvider>>> _apiProvidersGet({
    bool? searchEnabled,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Gets the list of enabled providers.',
      operationId: 'Provider_GetAvailableProviders',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Provider"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/providers');
    final Map<String, dynamic> $params = <String, dynamic>{
      'searchEnabled': searchEnabled,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<IProvider>, IProvider>($request);
  }

  @override
  Future<Response<List<IProvider>>> _apiProvidersAllGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets every provider regardless of enabled state (management view).',
      operationId: 'Provider_GetAllProviders',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Provider"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/providers/all');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<IProvider>, IProvider>($request);
  }

  @override
  Future<Response<IProvider>> _apiProvidersProviderIdPut({
    required String? providerId,
    required UpdateProviderRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Updates a provider\'s configuration.',
      operationId: 'Provider_UpdateProvider',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Provider"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/providers/${providerId}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<IProvider, IProvider>($request);
  }

  @override
  Future<Response<List<ISearchFilter>>>
  _apiProvidersProviderIdSearchFiltersGet({
    required String? providerId,
    String? mediaCategory,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets the available search filters for a given provider and a media category',
      operationId: 'Provider_GetProviderFilters',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Provider"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/providers/${providerId}/search-filters');
    final Map<String, dynamic> $params = <String, dynamic>{
      'mediaCategory': mediaCategory,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<ISearchFilter>, ISearchFilter>($request);
  }

  @override
  Future<Response<PaginatedResponseOfProviderSearchItemDto>>
  _apiProvidersProviderIdSearchPost({
    required String? providerId,
    required ApiMediaSearchRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Search the provider website and gets the results. The results are paginated.',
      operationId: 'Provider_Search',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Provider"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/providers/${providerId}/search');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      PaginatedResponseOfProviderSearchItemDto,
      PaginatedResponseOfProviderSearchItemDto
    >($request);
  }

  @override
  Future<Response<LiveTvSourceResult>> _apiSettingsLiveTvSourceGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets the Live TV channel source (DB value, or config fallback when never saved).',
      operationId: 'Settings_GetLiveTvSource',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Settings"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/settings/live-tv-source');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<LiveTvSourceResult, LiveTvSourceResult>($request);
  }

  @override
  Future<Response<LiveTvSourceResult>> _apiSettingsLiveTvSourcePut({
    required UpdateLiveTvSourceRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Updates the Live TV channel source. Applies from the next LiveTvChannelsJob run.',
      operationId: 'Settings_UpdateLiveTvSource',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Settings"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/settings/live-tv-source');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<LiveTvSourceResult, LiveTvSourceResult>($request);
  }

  @override
  Future<Response<List<String>>> _apiSettingsLiveTvSourceCountriesGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets the list of countries the current Live TV source exposes (empty if it can\'t be reached).',
      operationId: 'Settings_GetLiveTvSourceCountries',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Settings"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/settings/live-tv-source/countries');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<dynamic>> _apiTorrentsUploadPost({
    List<int>? file,
    String? mediaName,
    dynamic mediaCategory,
    String? authorId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'Torrent_UploadTorrent',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Torrent"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/torrents/upload');
    final List<PartValue> $parts = <PartValue>[
      PartValue<String?>('mediaName', mediaName),
      PartValue<dynamic>('mediaCategory', mediaCategory),
      PartValue<String?>('authorId', authorId),
      PartValueFile<List<int>?>('file', file),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<ReadyNotificationsResponse>> _apiNotificationsGet({
    String? xJellyfinToken,
    int? afterId,
    int? limit,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets the caller\'s ready-to-watch events after the given id, oldest first.',
      operationId: 'Notifications_GetNotifications',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications');
    final Map<String, dynamic> $params = <String, dynamic>{
      'afterId': afterId,
      'limit': limit,
    };
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<ReadyNotificationsResponse, ReadyNotificationsResponse>(
      $request,
    );
  }

  @override
  Future<Response<NotificationPreferencesDto>> _apiNotificationsPreferencesGet({
    String? xJellyfinToken,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets the caller\'s notification preferences (defaults when none stored).',
      operationId: 'Notifications_GetPreferences',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications/preferences');
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<NotificationPreferencesDto, NotificationPreferencesDto>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> _apiNotificationsPreferencesPut({
    String? xJellyfinToken,
    required NotificationPreferencesDto? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Updates the caller\'s notification preferences.',
      operationId: 'Notifications_UpdatePreferences',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications/preferences');
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<SeriesSubscriptionDto>>
  _apiNotificationsSubscriptionsSeriesIdGet({
    String? xJellyfinToken,
    required String? seriesId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets whether the caller follows the series and whether JellyBot tracks it.',
      operationId: 'Notifications_GetSubscription',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications/subscriptions/${seriesId}');
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<SeriesSubscriptionDto, SeriesSubscriptionDto>($request);
  }

  @override
  Future<Response<dynamic>> _apiNotificationsSubscriptionsSeriesIdPut({
    String? xJellyfinToken,
    required String? seriesId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Subscribes the caller to the series.',
      operationId: 'Notifications_Subscribe',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications/subscriptions/${seriesId}');
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiNotificationsSubscriptionsSeriesIdDelete({
    String? xJellyfinToken,
    required String? seriesId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: 'Unsubscribes the caller from the series.',
      operationId: 'Notifications_Unsubscribe',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications/subscriptions/${seriesId}');
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<ReadyNotificationHistoryResponse>>
  _apiNotificationsHistoryGet({
    String? xJellyfinToken,
    int? beforeId,
    int? limit,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Gets the caller\'s ready-to-watch events before the given id, newest first.',
      operationId: 'Notifications_GetHistory',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications/history');
    final Map<String, dynamic> $params = <String, dynamic>{
      'beforeId': beforeId,
      'limit': limit,
    };
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<
      ReadyNotificationHistoryResponse,
      ReadyNotificationHistoryResponse
    >($request);
  }

  @override
  Future<Response<dynamic>> _apiNotificationsReadPut({
    String? xJellyfinToken,
    required MarkNotificationsReadRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary:
          'Marks the caller\'s events read up to the given id (the stored value only moves forward).',
      operationId: 'Notifications_MarkRead',
      consumes: [],
      produces: [],
      security: [],
      tags: ["Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/notifications/read');
    final Map<String, String> $headers = {
      if (xJellyfinToken != null) 'X-Jellyfin-Token': xJellyfinToken,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
