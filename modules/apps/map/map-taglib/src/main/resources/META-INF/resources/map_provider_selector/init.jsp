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

<%@ include file="/init.jsp" %>

<%
String namespace = AUIUtil.getNamespace(liferayPortletRequest, liferayPortletResponse);

String configurationPrefix = GetterUtil.getString(request.getAttribute("liferay-map:map-provider-selector:configurationPrefix"), "TypeSettingsProperties");
String name = GetterUtil.getString(request.getAttribute("liferay-map:map-provider-selector:name"));
String mapProviderKey = GetterUtil.getString(request.getAttribute("liferay-map:map-provider-selector:mapProviderKey"));
Collection<MapProvider> mapProviders = (Collection<MapProvider>)request.getAttribute("liferay-map:map-provider-selector:mapProviders");
%>