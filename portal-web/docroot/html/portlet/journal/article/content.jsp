<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/journal/init.jsp" %>

<%
String redirect = (String)request.getAttribute("edit_article.jsp-redirect");

String portletResource = ParamUtil.getString(request, "portletResource");

JournalArticle article = (JournalArticle)request.getAttribute(WebKeys.JOURNAL_ARTICLE);

long groupId = BeanParamUtil.getLong(article, request, "groupId", scopeGroupId);

long classNameId = ParamUtil.getLong(request, "classNameId");
String classPK = ParamUtil.getString(request, "classPK");

String articleId = BeanParamUtil.getString(article, request, "articleId");
String newArticleId = ParamUtil.getString(request, "newArticleId");

DDMStructure ddmStructure = (DDMStructure)request.getAttribute("edit_article.jsp-structure");

DDMTemplate ddmTemplate = (DDMTemplate)request.getAttribute("edit_article.jsp-template");

String defaultLanguageId = (String)request.getAttribute("edit_article.jsp-defaultLanguageId");
String toLanguageId = (String)request.getAttribute("edit_article.jsp-toLanguageId");

Locale[] locales = LanguageUtil.getAvailableLocales(themeDisplay.getSiteGroupId());

Fields ddmFields = null;

if (article != null) {
	String content = null;

	if (Validator.isNotNull(toLanguageId)) {
		content = JournalArticleImpl.getContentByLocale(article.getDocument(), toLanguageId);
	}
	else {
		content = JournalArticleImpl.getContentByLocale(article.getDocument(), defaultLanguageId);
	}

	if (Validator.isNotNull(content)) {
		ddmFields = JournalConverterUtil.getDDMFields(ddmStructure, content);
	}
}

String requestedLanguageId = defaultLanguageId;

if (Validator.isNotNull(toLanguageId)) {
	requestedLanguageId = toLanguageId;
}

Locale[] availableLocales = new Locale[0];

if (ddmFields != null) {
	Set<Locale> availableLocalesSet = ddmFields.getAvailableLocales();

	availableLocales = availableLocalesSet.toArray(new Locale[availableLocalesSet.size()]);
}

%>

<liferay-ui:error-marker key="errorSection" value="content" />

<aui:model-context bean="<%= article %>" defaultLanguageId="<%= defaultLanguageId %>" model="<%= JournalArticle.class %>" />

<portlet:renderURL var="editArticleRenderPopUpURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
	<portlet:param name="struts_action" value="/journal/edit_article" />
	<portlet:param name="articleId" value="<%= articleId %>" />
	<portlet:param name="groupId" value="<%= String.valueOf(groupId) %>" />
	<portlet:param name="structureId" value="<%= ddmStructure.getStructureKey() %>" />
</portlet:renderURL>

<div class="journal-article-body" id="<portlet:namespace />journalArticleBody">
	<div class="journal-article-body-content">
		<liferay-ui:error exception="<%= ArticleContentException.class %>" message="please-enter-valid-content" />
		<liferay-ui:error exception="<%= ArticleIdException.class %>" message="please-enter-a-valid-id" />
		<liferay-ui:error exception="<%= ArticleTitleException.class %>" message="please-enter-a-valid-name" />
		<liferay-ui:error exception="<%= ArticleVersionException.class %>" message="another-user-has-made-changes-since-you-started-editing-please-copy-your-changes-and-try-again" />
		<liferay-ui:error exception="<%= DuplicateArticleIdException.class %>" message="please-enter-a-unique-id" />
		<liferay-ui:error exception="<%= InvalidDDMStructureException.class %>" message="the-structure-you-selected-is-not-valid-for-this-folder" />
		<liferay-ui:error exception="<%= StorageFieldRequiredException.class %>" message="please-fill-out-all-required-fields" />

		<liferay-ui:error exception="<%= LocaleException.class %>">

			<%
			LocaleException le = (LocaleException)errorException;
			%>

			<c:if test="<%= le.getType() == LocaleException.TYPE_CONTENT %>">
				<liferay-ui:message arguments="<%= new String[] {StringUtil.merge(le.getSourceAvailableLocales(), StringPool.COMMA_AND_SPACE), StringUtil.merge(le.getTargetAvailableLocales(), StringPool.COMMA_AND_SPACE)} %>" key="the-default-language-x-does-not-match-the-portal's-available-languages-x" />
			</c:if>
		</liferay-ui:error>

		<div class="journal-article-header-edit" id="<portlet:namespace />articleHeaderEdit">
			<div class="journal-article-header-id">
				<c:if test="<%= (article == null) || article.isNew() %>">
					<c:choose>
						<c:when test="<%= PropsValues.JOURNAL_ARTICLE_FORCE_AUTOGENERATE_ID || (classNameId != JournalArticleConstants.CLASSNAME_ID_DEFAULT) %>">
							<aui:input name="newArticleId" type="hidden" />
							<aui:input name="autoArticleId" type="hidden" value="<%= true %>" />
						</c:when>
						<c:otherwise>
							<aui:input autoFocus="<%= windowState.equals(WindowState.MAXIMIZED) || windowState.equals(LiferayWindowState.POP_UP) %>" cssClass="lfr-input-text-container" field="articleId" fieldParam="newArticleId" label="id" name="newArticleId" value="<%= newArticleId %>" />

							<aui:input label="autogenerate-id" name="autoArticleId" type="checkbox" />
						</c:otherwise>
					</c:choose>
				</c:if>
			</div>

			<c:if test="<%= Validator.isNull(toLanguageId) %>">
				<div class="article-structure-template-toolbar journal-metadata">
					<span class="alert alert-warning hide structure-message" id="<portlet:namespace />structureMessage">
						<liferay-ui:message key="this-structure-has-not-been-saved" />

						<liferay-ui:message arguments='<%= new Object[] {"journal-save-structure-trigger", "#"} %>' key="click-here-to-save-it-now" />
					</span>

					<aui:row>
						<aui:col cssClass="article-structure" width="<%= 50 %>">
							<span class="article-structure-label"><liferay-ui:message key="structure" />:</span>

							<aui:fieldset cssClass="article-structure-toolbar">
								<div class="journal-form-presentation-label">
									<aui:input name="groupId" type="hidden" value="<%= groupId %>" />
									<aui:input name="structureId" type="hidden" value="<%= ddmStructure.getStructureKey() %>" />
									<aui:input name="structureName" type="hidden" value="<%= ddmStructure.getName(locale) %>" />
									<aui:input name="structureDescription" type="hidden" value="<%= ddmStructure.getDescription(locale) %>" />

									<span class="structure-name-label" id="<portlet:namespace />structureNameLabel">
										<c:choose>
											<c:when test="<%= DDMStructurePermission.contains(permissionChecker, ddmStructure, PortletKeys.JOURNAL, ActionKeys.UPDATE) %>">
												<aui:a href="javascript:;" id="editDDMStructure" label="<%= HtmlUtil.escape(ddmStructure.getName(locale)) %>" />
											</c:when>
											<c:otherwise>
												<%= HtmlUtil.escape(ddmStructure.getName(locale)) %>
											</c:otherwise>
										</c:choose>
									</span>

									<c:if test="<%= classNameId == JournalArticleConstants.CLASSNAME_ID_DEFAULT %>">
										<liferay-ui:icon
											iconCssClass="icon-search"
											id="selectStructure"
											label="<%= true %>"
											linkCssClass="btn btn-default"
											message="select"
											url="javascript:;"
										/>
									</c:if>
								</div>
							</aui:fieldset>
						</aui:col>

						<aui:col cssClass="article-template" width="<%= 50 %>">
							<span class="article-template-label"><liferay-ui:message key="template" />:</span>

							<aui:fieldset cssClass="article-template-toolbar">
								<div class="journal-form-presentation-label">
									<aui:input name="templateId" type="hidden" value="<%= (ddmTemplate != null) ? ddmTemplate.getTemplateKey() : StringPool.BLANK %>" />

									<span class="template-name-label" id="<portlet:namespace />templateNameLabel">
										<c:if test="<%= (ddmTemplate != null) && ddmTemplate.isSmallImage() %>">
											<img alt="" class="article-template-image" id="<portlet:namespace />templateImage" src="<%= HtmlUtil.escapeAttribute(_getTemplateImage(themeDisplay, ddmTemplate)) %>" />
										</c:if>

										<c:choose>
											<c:when test="<%= (ddmTemplate != null) && DDMTemplatePermission.contains(permissionChecker, scopeGroupId, ddmTemplate, PortletKeys.JOURNAL, ActionKeys.UPDATE) %>">
												<aui:a href="javascript:;" id="editDDMTemplate" label="<%= HtmlUtil.escape(ddmTemplate.getName(locale)) %>" />
											</c:when>
											<c:otherwise>
												<%= (ddmTemplate != null) ? HtmlUtil.escape(ddmTemplate.getName(locale)) : LanguageUtil.get(request, "none") %>
											</c:otherwise>
										</c:choose>
									</span>

									<liferay-ui:icon
										iconCssClass="icon-search"
										id="selectTemplate"
										label="<%= true %>"
										linkCssClass="btn btn-default"
										message="select"
										url="javascript:;"
									/>
								</div>
							</aui:fieldset>
						</aui:col>
					</aui:row>
				</div>
			</c:if>

			<aui:translation-manager
				availableLocales="<%= availableLocales %>"
				defaultLanguageId="<%= defaultLanguageId %>"
				id="translationManager"
			/>
		</div>

		<div class="journal-article-general-fields">
			<aui:input autoFocus="<%= (((article != null) && !article.isNew()) && !PropsValues.JOURNAL_ARTICLE_FORCE_AUTOGENERATE_ID && windowState.equals(WindowState.MAXIMIZED)) || windowState.equals(LiferayWindowState.POP_UP) %>" defaultLanguageId="<%= Validator.isNotNull(toLanguageId) ? toLanguageId : defaultLanguageId %>" languageId="<%= Validator.isNotNull(toLanguageId) ? toLanguageId : defaultLanguageId %>" name="title">
				<c:if test="<%= classNameId == JournalArticleConstants.CLASSNAME_ID_DEFAULT %>">
					<aui:validator name="required" />
				</c:if>
			</aui:input>
		</div>

		<div class="journal-article-container" id="<portlet:namespace />journalArticleContainer">

			<liferay-ddm:html
				checkRequired="<%= classNameId == JournalArticleConstants.CLASSNAME_ID_DEFAULT %>"
				classNameId="<%= PortalUtil.getClassNameId(DDMStructure.class) %>"
				classPK="<%= ddmStructure.getStructureId() %>"
				fields="<%= ddmFields %>"
				repeatable="<%= Validator.isNull(toLanguageId) %>"
				requestedLocale="<%= LocaleUtil.fromLanguageId(requestedLanguageId) %>"
			/>

			<c:if test="<%= Validator.isNull(toLanguageId) %>">
				<aui:input label="searchable" name="indexable" />
			</c:if>
		</div>
	</div>

	<c:if test="<%= Validator.isNotNull(toLanguageId) %>">
		<aui:input name="structureId" type="hidden" value="<%= ddmStructure.getStructureKey() %>" />
	</c:if>
</div>

<liferay-portlet:renderURL portletName="<%= PortletKeys.DYNAMIC_DATA_MAPPING %>" var="editStructureURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
	<portlet:param name="struts_action" value="/dynamic_data_mapping/edit_structure" />
	<portlet:param name="closeRedirect" value="<%= currentURL %>" />
	<portlet:param name="showBackURL" value="<%= Boolean.FALSE.toString() %>" />
	<portlet:param name="refererPortletName" value="<%= PortletKeys.JOURNAL %>" />
	<portlet:param name="groupId" value="<%= String.valueOf(groupId) %>" />
	<portlet:param name="classNameId" value="<%= String.valueOf(PortalUtil.getClassNameId(DDMStructure.class)) %>" />
	<portlet:param name="classPK" value="<%= String.valueOf(ddmStructure.getStructureId()) %>" />
</liferay-portlet:renderURL>

<liferay-portlet:renderURL portletName="<%= PortletKeys.DYNAMIC_DATA_MAPPING %>" var="editTemplateURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
	<portlet:param name="struts_action" value="/dynamic_data_mapping/edit_template" />
	<portlet:param name="closeRedirect" value="<%= currentURL %>" />
	<portlet:param name="showBackURL" value="<%= Boolean.FALSE.toString() %>" />
	<portlet:param name="refererPortletName" value="<%= PortletKeys.JOURNAL %>" />
	<portlet:param name="groupId" value="<%= String.valueOf(groupId) %>" />
	<portlet:param name="classNameId" value="<%= String.valueOf(classNameId) %>" />
	<portlet:param name="templateId" value="<%= (ddmTemplate != null) ? String.valueOf(ddmTemplate.getTemplateId()) : StringPool.BLANK %>" />
</liferay-portlet:renderURL>

<portlet:renderURL var="updateDefaultLanguageURL" windowState="<%= WindowState.MAXIMIZED.toString() %>">
	<portlet:param name="struts_action" value="/journal/edit_article" />
	<portlet:param name="redirect" value="<%= redirect %>" />
	<portlet:param name="portletResource" value="<%= portletResource %>" />
	<portlet:param name="articleId" value="<%= articleId %>" />
	<portlet:param name="groupId" value="<%= String.valueOf(groupId) %>" />
	<portlet:param name="classNameId" value="<%= String.valueOf(classNameId) %>" />
	<portlet:param name="classPK" value="<%= classPK %>" />
	<portlet:param name="structureId" value="<%= ddmStructure.getStructureKey() %>" />
	<portlet:param name="templateId" value="<%= (ddmTemplate != null) ? String.valueOf(ddmTemplate.getTemplateKey()) : StringPool.BLANK %>" />
</portlet:renderURL>

<aui:script use="liferay-journal-content">
	var journalContent = new Liferay.Portlet.JournalContent(
		{
			'ddm.basePortletURL': '<%= PortletURLFactoryUtil.create(request, PortletKeys.DYNAMIC_DATA_MAPPING, themeDisplay.getPlid(), PortletRequest.RENDER_PHASE) %>',
			'ddm.classNameId': '<%= PortalUtil.getClassNameId(DDMStructure.class) %>',
			'ddm.classPK': <%= ddmStructure.getPrimaryKey() %>,
			'ddm.groupId': <%= groupId %>,
			'ddm.refererPortletName': '<%= PortletKeys.JOURNAL_CONTENT %>',
			'ddm.templateId': <%= (ddmTemplate != null) ? ddmTemplate.getTemplateId() : 0 %>,
			editStructure: '#<portlet:namespace />editDDMStructure',
			editTemplate: '#<portlet:namespace />editDDMTemplate',
			namespace: '<portlet:namespace />',
			selectStructure: '#<portlet:namespace />selectStructure',
			selectTemplate: '#<portlet:namespace />selectTemplate',
			'urls.editStructure': '<%= editStructureURL %>',
			'urls.editTemplate': '<%= editTemplateURL %>',
			'urls.editTranslation': '<%= editArticleRenderPopUpURL %>',
			'urls.updateDefaultLanguage': '<%= updateDefaultLanguageURL %>'
		}
	);

	Liferay.Util.disableToggleBoxes('<portlet:namespace />autoArticleId','<portlet:namespace />newArticleId', true);
</aui:script>

<%!
private String _getTemplateImage(ThemeDisplay themeDisplay, DDMTemplate ddmTemplate) {
	String imageURL = null;

	if (ddmTemplate.isSmallImage()) {
		if (Validator.isNotNull(ddmTemplate.getSmallImageURL())) {
			imageURL = ddmTemplate.getSmallImageURL();
		}
		else {
			imageURL = themeDisplay.getPathImage() + "/journal/template?img_id=" + ddmTemplate.getSmallImageId() + "&t=" + WebServerServletTokenUtil.getToken(ddmTemplate.getSmallImageId());
		}
	}

	return imageURL;
}
%>