<%@ page import="java.sql.*,java.util.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Search Results</title>
    </head>

    <body>
        <h3>Search Results</h3>
        <a href="mainPage.jsp">Back to Main Page</a>
        <hr />

        <% String itemType=request.getParameter("itemType"); if (itemType==null || itemType.trim().isEmpty()) {
            out.println("<p>Please select an item type to search.</p>");
            } else {

            itemType = itemType.trim();



            String jdbcUrl = "jdbc:mysql://localhost:3306/thriftShop";
            String dbUser = "root";
            String dbPass = "12345";

            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
            Statement st = con.createStatement()) {

            StringBuilder sql = new StringBuilder("SELECT * FROM " + itemType + " WHERE 1=1");

            // common fields
            String gender = null;
            String size = null;
            String color = null;
            String description = null;
            String condition = null;

            // tops extra
            String frontLen = null;
            String chestLen = null;
            String sleeveLen = null;

            // bottoms extra
            String waistLen = null;
            String inseamLen = null;
            String outseamLen = null;
            String hipLen = null;
            String riseLen = null;

            // price
            String minPrice = request.getParameter("searchMinPrice");
            String maxPrice = request.getParameter("searchMaxPrice");

            // read per item type
            if ("tops".equals(itemType)) {
            gender = request.getParameter("searchTopGender");
            size = request.getParameter("searchTopSize");
            color = request.getParameter("searchTopColor");
            frontLen = request.getParameter("searchTopFrontLength");
            chestLen = request.getParameter("searchTopChestLength");
            sleeveLen = request.getParameter("searchTopSleeveLength");
            description = request.getParameter("searchTopDescription");
            condition = request.getParameter("searchTopCondition");
            } else if ("bottoms".equals(itemType)) {
            gender = request.getParameter("searchBottomGender");
            size = request.getParameter("searchBottomSize");
            color = request.getParameter("searchBottomColor");
            waistLen = request.getParameter("searchBottomWaistLength");
            inseamLen = request.getParameter("searchBottomInseamLength");
            outseamLen = request.getParameter("searchBottomOutseamLength");
            hipLen = request.getParameter("searchBottomHipLength");
            riseLen = request.getParameter("searchBottomRiseLength");
            description = request.getParameter("searchBottomDescription");
            condition = request.getParameter("searchBottomCondition");
            } else if ("shoes".equals(itemType)) {
            gender = request.getParameter("searchShoeGender");
            size = request.getParameter("searchShoeSize");
            color = request.getParameter("searchShoeColor");
            description = request.getParameter("searchShoeDescription");
            condition = request.getParameter("searchShoeCondition");
            }

            // trim
            if (gender != null) gender = gender.trim();
            if (size != null) size = size.trim();
            if (color != null) color = color.trim();
            if (frontLen != null) frontLen = frontLen.trim();
            if (chestLen != null) chestLen = chestLen.trim();
            if (sleeveLen != null) sleeveLen = sleeveLen.trim();
            if (waistLen != null) waistLen = waistLen.trim();
            if (inseamLen != null) inseamLen = inseamLen.trim();
            if (outseamLen != null) outseamLen = outseamLen.trim();
            if (hipLen != null) hipLen = hipLen.trim();
            if (riseLen != null) riseLen = riseLen.trim();
            if (description != null) description = description.trim();
            if (condition != null) condition = condition.trim();
            if (minPrice != null) minPrice = minPrice.trim();
            if (maxPrice != null) maxPrice = maxPrice.trim();

            // treat "Any" as no filter
            if ("Any Gender".equalsIgnoreCase(gender)) gender = null;
            if ("Any Size".equalsIgnoreCase(size)) size = null;
            if ("Any Color".equalsIgnoreCase(color)) color = null;


            // common filters
            if (gender != null && !gender.isEmpty()) {
            sql.append(" AND genderValue = '").append(gender).append("'");
            }
            if (size != null && !size.isEmpty()) {
            sql.append(" AND sizeValue = '").append(size).append("'");
            }
            if (color != null && !color.isEmpty()) {
            sql.append(" AND colorValue = '").append(color).append("'");
            }

            // tops numeric filters
            if ("tops".equals(itemType)) {
            if (frontLen != null && !frontLen.isEmpty()) {
            // change column names if needed
            sql.append(" AND frontLengthValue = ").append(frontLen);
            }
            if (chestLen != null && !chestLen.isEmpty()) {
            sql.append(" AND chestLengthValue = ").append(chestLen);
            }
            if (sleeveLen != null && !sleeveLen.isEmpty()) {
            sql.append(" AND sleeveLengthValue = ").append(sleeveLen);
            }
            }

            // bottoms numeric filters
            if ("bottoms".equals(itemType)) {
            if (waistLen != null && !waistLen.isEmpty()) {
            sql.append(" AND waistLengthValue = ").append(waistLen);
            }
            if (inseamLen != null && !inseamLen.isEmpty()) {
            sql.append(" AND inseamLengthValue = ").append(inseamLen);
            }
            if (outseamLen != null && !outseamLen.isEmpty()) {
            sql.append(" AND outseamLengthValue = ").append(outseamLen);
            }
            if (hipLen != null && !hipLen.isEmpty()) {
            sql.append(" AND hipLengthValue = ").append(hipLen);
            }
            if (riseLen != null && !riseLen.isEmpty()) {
            sql.append(" AND riseLengthValue = ").append(riseLen);
            }
            }

            // description like
            if (description != null && !description.isEmpty()) {
            String safeDesc = description.replace("'", "''");
            sql.append(" AND descriptionValue LIKE '%").append(safeDesc).append("%'");
            }

            // condition
            if (condition != null && !condition.isEmpty()) {
            sql.append(" AND conditionValue = '").append(condition).append("'");
            }

            // price
            if (minPrice != null && !minPrice.isEmpty()) {
            sql.append(" AND minimumBidPriceValue >= ").append(minPrice);
            }
            if (maxPrice != null && !maxPrice.isEmpty()) {
            sql.append(" AND minimumBidPriceValue <= ").append(maxPrice);
            }


            ResultSet rs = st.executeQuery(sql.toString());
            boolean found = false;

            String idCol = null;
            if (" tops".equals(itemType)) { idCol="topIdValue" ; } else if ("bottoms".equals(itemType)) {
                idCol="bottomIdValue" ; } else if ("shoes".equals(itemType)) { idCol="shoeIdValue" ; } while (rs.next())
                { found=true; %>
                <div style="border:1px solid #ccc; margin:10px; padding:10px;">
                    <% if (idCol !=null) { %>
                        <p><strong>Item ID:</strong>
                            <%= rs.getString(idCol) %>
                        </p>
                        <% } %>
                            <p><strong>Gender:</strong>
                                <%= rs.getString("genderValue") %>
                            </p>
                            <p><strong>Size:</strong>
                                <%= rs.getString("sizeValue") %>
                            </p>
                            <p><strong>Color:</strong>
                                <%= rs.getString("colorValue") %>
                            </p>
                            <p><strong>Description:</strong>
                                <%= rs.getString("descriptionValue") %>
                            </p>
                            <p><strong>Condition:</strong>
                                <%= rs.getString("conditionValue") %>
                            </p>
                            <p><strong>Price:</strong> $<%= rs.getString("minimumBidPriceValue") %>
                            </p>
                </div>
                <% } if (!found) { out.println("<p>No items found matching your criteria.</p>");
                    }

                    rs.close();
                    } catch (Exception e) {
                    out.println("Error: " + e.getMessage());
                    }
                    }
                    %>

    </body>

    </html>