<%--
/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
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

<%@ page import="com.liferay.portlet.dynamicdatamapping.TemplateSmallImageNameException" %>
<%@ page import="com.liferay.portlet.dynamicdatamapping.TemplateSmallImageSizeException" %>

<%@ include file="/html/portlet/dynamic_data_mapping/init.jsp" %>

<%
String redirect = ParamUtil.getString(request, "redirect");
String backURL = ParamUtil.getString(request, "backURL");

String portletResource = ParamUtil.getString(request, "portletResource");

String portletResourceNamespace = ParamUtil.getString(request, "portletResourceNamespace");

DDMTemplate template = (DDMTemplate)request.getAttribute(WebKeys.DYNAMIC_DATA_MAPPING_TEMPLATE);

long templateId = BeanParamUtil.getLong(template, request, "templateId");

long groupId = BeanParamUtil.getLong(template, request, "groupId", scopeGroupId);
long classNameId = BeanParamUtil.getLong(template, request, "classNameId");
long classPK = BeanParamUtil.getLong(template, request, "classPK");

boolean isSmallImage = BeanParamUtil.getBoolean(template, request, "smallImage");

DDMStructure structure = (DDMStructure)request.getAttribute(WebKeys.DYNAMIC_DATA_MAPPING_STRUCTURE);

if ((structure == null) && (template != null)) {
	structure = DDMTemplateHelperUtil.fetchStructure(template);
}

String type = BeanParamUtil.getString(template, request, "type", DDMTemplateConstants.TEMPLATE_TYPE_FORM);
String mode = BeanParamUtil.getString(template, request, "mode", DDMTemplateConstants.TEMPLATE_MODE_CREATE);
String language = BeanParamUtil.getString(template, request, "language", DDMTemplateConstants.LANG_TYPE_VM);
String script = BeanParamUtil.getString(template, request, "script");

if (Validator.isNull(script)) {
	if (classNameId > 0) {
		PortletDisplayTemplateHandler portletDisplayTemplateHandler = PortletDisplayTemplateHandlerRegistryUtil.getPortletDisplayTemplateHandler(classNameId);

		if (portletDisplayTemplateHandler != null) {
			script = ContentUtil.get(portletDisplayTemplateHandler.getTemplatesHelpPath(language));
		}
	}
	else if (!type.equals(DDMTemplateConstants.TEMPLATE_TYPE_FORM)) {
		script = ContentUtil.get(PropsUtil.get(PropsKeys.DYNAMIC_DATA_MAPPING_TEMPLATE_LANGUAGE_CONTENT, new Filter(DDMTemplateConstants.LANG_TYPE_VM)));
	}
}

JSONArray scriptJSONArray = null;

if (type.equals(DDMTemplateConstants.TEMPLATE_TYPE_FORM) && Validator.isNotNull(script)) {
	scriptJSONArray = DDMXSDUtil.getJSONArray(script);
}

String structureAvailableFields = ParamUtil.getString(request, "structureAvailableFields");

if (Validator.isNotNull(structureAvailableFields)) {
	scopeAvailableFields = structureAvailableFields;
}
%>

<portlet:actionURL var="editTemplateURL">
	<portlet:param name="struts_action" value="/dynamic_data_mapping/edit_template" />
</portlet:actionURL>

<aui:form action="<%= editTemplateURL %>" enctype="multipart/form-data" method="post" name="fm" onSubmit='<%= "event.preventDefault(); " + renderResponse.getNamespace() + "saveTemplate();" %>'>
	<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= (template != null) ? Constants.UPDATE : Constants.ADD %>" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
	<aui:input name="portletResource" type="hidden" value="<%= portletResource %>" />
	<aui:input name="templateId" type="hidden" value="<%= templateId %>" />
	<aui:input name="groupId" type="hidden" value="<%= groupId %>" />
	<aui:input name="classNameId" type="hidden" value="<%= classNameId %>" />
	<aui:input name="classPK" type="hidden" value="<%= classPK %>" />
	<aui:input name="type" type="hidden" value="<%= type %>" />
	<aui:input name="structureAvailableFields" type="hidden" value="<%= structureAvailableFields %>" />
	<aui:input name="saveCallback" type="hidden" value="<%= saveCallback %>" />
	<aui:input name="saveAndContinue" type="hidden" value="<%= false %>" />

	<liferay-ui:error exception="<%= TemplateNameException.class %>" message="please-enter-a-valid-name" />
	<liferay-ui:error exception="<%= TemplateScriptException.class %>" message="please-enter-a-valid-script" />

	<liferay-ui:error exception="<%= TemplateSmallImageNameException.class %>">

		<%
		String[] imageExtensions = PrefsPropsUtil.getStringArray(PropsKeys.DYNAMIC_DATA_MAPPING_IMAGE_EXTENSIONS, ",");
		%>

		<liferay-ui:message key="image-names-must-end-with-one-of-the-following-extensions" /> <%= StringUtil.merge(imageExtensions, StringPool.COMMA) %>.
	</liferay-ui:error>

	<liferay-ui:error exception="<%= TemplateSmallImageSizeException.class %>">

		<%
		long imageMaxSize = PrefsPropsUtil.getLong(PropsKeys.DYNAMIC_DATA_MAPPING_IMAGE_SMALL_MAX_SIZE) / 1024;
		%>

		<liferay-ui:message arguments="<%= imageMaxSize %>" key="please-enter-a-small-image-with-a-valid-file-size-no-larger-than-x" />
	</liferay-ui:error>

	<%
	String title = null;

	if (structure != null) {
		if (template != null) {
			title = template.getName(locale) + " (" + structure.getName(locale) + ")";
		}
		else {
			title = LanguageUtil.format(pageContext, "new-template-for-structure-x", structure.getName(locale), false);
		}
	}
	else if (template != null) {
		title = template.getName(locale);
	}
	else {
		if (classNameId > 0) {
			PortletDisplayTemplateHandler portletDisplayTemplateHandler = PortletDisplayTemplateHandlerRegistryUtil.getPortletDisplayTemplateHandler(classNameId);

			title = LanguageUtil.get(pageContext, "new") + StringPool.SPACE + portletDisplayTemplateHandler.getName(locale);
		}
		else {
			title = LanguageUtil.get(pageContext, "new-application-display-template");
		}
	}
	%>

	<portlet:renderURL var="viewTemplatesURL">
		<portlet:param name="struts_action" value="/dynamic_data_mapping/view_template" />
		<portlet:param name="classNameId" value="<%= String.valueOf(classNameId) %>" />
		<portlet:param name="classPK" value="<%= String.valueOf(classPK) %>" />
	</portlet:renderURL>

	<liferay-ui:header
		backURL="<%= (portletName.equals(PortletKeys.PORTLET_DISPLAY_TEMPLATES) || Validator.isNotNull(portletResource)) ? backURL : viewTemplatesURL %>"
		localizeTitle="<%= false %>"
		title="<%= title %>"
	/>

	<aui:model-context bean="<%= template %>" model="<%= DDMTemplate.class %>" />

	<aui:fieldset>
		<aui:input name="name" />

		<liferay-ui:panel-container cssClass="lfr-structure-entry-details-container" extended="<%= false %>" id="templateDetailsPanelContainer" persistState="<%= true %>">
			<liferay-ui:panel collapsible="<%= true %>" extended="<%= false %>" id="templateDetailsSectionPanel" persistState="<%= true %>" title="details">
				<aui:input name="description" />

				<c:if test="<%= template != null %>">
					<aui:field-wrapper label="url">
						<liferay-ui:input-resource url='<%= themeDisplay.getPortalURL() + themeDisplay.getPathMain() + "/dynamic_data_mapping/get_template?templateId=" + templateId %>' />
					</aui:field-wrapper>

					<c:if test="<%= portletDisplay.isWebDAVEnabled() %>">
						<aui:field-wrapper label="webdav-url">

							<%
							Group group = GroupLocalServiceUtil.getGroup(groupId);
							%>

							<liferay-ui:input-resource url='<%= themeDisplay.getPortalURL() + themeDisplay.getPathContext() + "/webdav" + group.getFriendlyURL() + "/dynamic_data_mapping/ddmTemplates/" + templateId %>' />
						</aui:field-wrapper>
					</c:if>
				</c:if>

				<c:choose>
					<c:when test="<%= type.equals(DDMTemplateConstants.TEMPLATE_TYPE_DETAIL) %>">
						<aui:select helpMessage="only-allow-deleting-required-fields-in-edit-mode" label="mode" name="mode">
							<aui:option label="create" />
							<aui:option label="edit" />
						</aui:select>

						<aui:script use="aui-base,event-valuechange">
							A.one('#<portlet:namespace />mode').on(
								'valueChange',
								function(event) {
									<portlet:namespace />toggleMode(event.newVal);
								}
							);
						</aui:script>
					</c:when>
					<c:otherwise>
						<div id="<portlet:namespace />smallImageContainer">
							<div class="lfr-ddm-small-image-header">
								<aui:input name="smallImage" />
							</div>
							<div class="lfr-ddm-small-image-content aui-toggler-content-collapsed">
								<table>
									<tr>
										<th>
											<div class="lfr-ddm-small-image-preview">
												<c:if test="<%= isSmallImage %>">
													<style>
														.lfr-ddm-small-image-preview div {
															background: url(<%= Validator.isNotNull(template.getSmallImageURL()) ? template.getSmallImageURL() : themeDisplay.getPathImage() + "/template?img_id=" + template.getSmallImageId() + "&t=" + WebServerServletTokenUtil.getToken(template.getSmallImageId()) %>) !important;
														}
													</style>
												</c:if>

												<div></div>
											</div>
										</th>
										<td>
											<table>
												<tr>
													<th>
														<aui:input inputCssClass="lfr-ddm-small-image-type" label="small-image-url" name="type" type="radio" />
													</th>
													<td>
														<aui:input inputCssClass="lfr-ddm-small-image-value" label="" name="smallImageURL" />
													</td>
												</tr>
												<tr>
													<th>
														<aui:input inputCssClass="lfr-ddm-small-image-type" label="small-image" name="type" type="radio" />
													</th>
													<td>
														<aui:input inputCssClass="lfr-ddm-small-image-value" label="" name="smallImageFile" type="file" />
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</table>
							</div>
						</div>
					</c:otherwise>
				</c:choose>
			</liferay-ui:panel>
		</liferay-ui:panel-container>

		<c:choose>
			<c:when test="<%= type.equals(DDMTemplateConstants.TEMPLATE_TYPE_FORM) %>">
				<%@ include file="/html/portlet/dynamic_data_mapping/edit_template_form.jspf" %>
			</c:when>
			<c:otherwise>
				<%@ include file="/html/portlet/dynamic_data_mapping/edit_template_display.jspf" %>
			</c:otherwise>
		</c:choose>
	</aui:fieldset>
</aui:form>

<c:choose>
	<c:when test="<%= type.equals(DDMTemplateConstants.TEMPLATE_TYPE_FORM) %>">
		<%@ include file="/html/portlet/dynamic_data_mapping/form_builder.jspf" %>

		<aui:script use="aui-base">
			var hiddenAttributesMap = window.<portlet:namespace />formBuilder.MAP_HIDDEN_FIELD_ATTRS;

			window.<portlet:namespace />getFieldHiddenAttributes = function(mode, field) {
				var hiddenAttributes = hiddenAttributesMap[field.get('type')] || hiddenAttributesMap.DEFAULT;

				hiddenAttributes = A.Array(hiddenAttributes);

				if (mode === '<%= DDMTemplateConstants.TEMPLATE_MODE_EDIT %>') {
					A.Array.removeItem(hiddenAttributes, 'readOnly');
				}

				return hiddenAttributes;
			};

			window.<portlet:namespace />toggleMode = function(mode) {
				var modeEdit = (mode === '<%= DDMTemplateConstants.TEMPLATE_MODE_EDIT %>');

				window.<portlet:namespace />formBuilder.set('allowRemoveRequiredFields', modeEdit);

				window.<portlet:namespace />formBuilder.get('fields').each(
					function(item, index, collection) {
						var hiddenAttributes = window.<portlet:namespace />getFieldHiddenAttributes(mode, item);

						item.set('hiddenAttributes', hiddenAttributes);
					}
				);

				A.Array.each(
					window.<portlet:namespace />formBuilder.get('availableFields'),
					function(item, index, collection) {
						var hiddenAttributes = window.<portlet:namespace />getFieldHiddenAttributes(mode, item);

						item.set('hiddenAttributes', hiddenAttributes);
					}
				);
			};

			<portlet:namespace />toggleMode('<%= HtmlUtil.escape(mode) %>');
		</aui:script>
	</c:when>
	<c:otherwise>
		<aui:script use="aui-toggler">
			var <portlet:namespace />container = A.one('#<portlet:namespace />smallImageContainer');
			var <portlet:namespace />preview = <portlet:namespace />container.one('.lfr-ddm-small-image-preview div');
			var <portlet:namespace />types = <portlet:namespace />container.all('.lfr-ddm-small-image-type');
			var <portlet:namespace />values = <portlet:namespace />container.all('.lfr-ddm-small-image-value');

			var <portlet:namespace />selectSmallImageType = function(index) {
				<portlet:namespace />types.set('checked', false);
				<portlet:namespace />types.item(index).set('checked', true);

				<portlet:namespace />values.set('disabled', true);
				<portlet:namespace />values.item(index).set('disabled', false);
			};

			<portlet:namespace />container.delegate(
				'change',
				function(event) {
					var input = event.currentTarget;
					var index = <portlet:namespace />types.indexOf(input);

					<portlet:namespace />selectSmallImageType(index);
				},
				'.lfr-ddm-small-image-type'
			);

			var <portlet:namespace />toggler = new A.Toggler(
				{
					on: {
						animatingChange: function(event) {
							var instance = this;
							var expanded = !instance.get('expanded');

							A.one('#<portlet:namespace />smallImageCheckbox').set('checked', expanded);
							A.one('#<portlet:namespace />smallImage').set('value', expanded);

							if (expanded) {
								<portlet:namespace />types.each(function (type, index) {
									if (type.get('checked')) {
										<portlet:namespace />values.item(index).set('disabled', false);
									}
								});
							}
							else {
								<portlet:namespace />values.set('disabled', true);
							}
						}
					},
					animated: true,
					content: '#<portlet:namespace />smallImageContainer .lfr-ddm-small-image-content',
					header: '#<portlet:namespace />smallImageContainer .lfr-ddm-small-image-header',
					expanded: <%= isSmallImage %>
				}
			);

			<portlet:namespace />selectSmallImageType('<%= (template != null) && Validator.isNotNull(template.getSmallImageURL()) ? 0 : 1 %>');
		</aui:script>
	</c:otherwise>
</c:choose>

<aui:button-row>
	<aui:button onClick='<%= renderResponse.getNamespace() + "saveTemplate();" %>' value='<%= LanguageUtil.get(pageContext, "save") %>' />

	<aui:button href="<%= redirect %>" type="cancel" />
</aui:button-row>